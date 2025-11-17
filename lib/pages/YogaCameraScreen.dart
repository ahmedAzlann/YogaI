import 'dart:async';
import 'dart:convert';
import 'dart:io'; // <-- needed for Platform.isIOS
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart'; // <-- INPUT IMAGE CLASSES
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class YogaCameraScreen extends StatefulWidget {
  const YogaCameraScreen({super.key});

  @override
  State<YogaCameraScreen> createState() => _YogaCameraScreenState();
}

class _YogaCameraScreenState extends State<YogaCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isPermissionGranted = false;
  bool _isCameraInitialized = false;

  // ML & stream variables
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  PoseDetector? _poseDetector;
  Interpreter? _interpreter;
  Map<String, String> _labels = {};
  String _detectedPose = "Initializing...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
    _loadModels();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    runZoned(() async {
      await _controller?.stopImageStream();
      await _controller?.dispose();
    });
    _poseDetector?.close();
    _interpreter?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _controller;
    if (cam == null || !cam.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cam.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // ---------- MODEL LOADING ----------
  Future<void> _loadModels() async {
    try {
      final labelsData = await rootBundle.loadString(
        'assets/models/pose_labels.json',
      );
      final map = jsonDecode(labelsData) as Map<String, dynamic>;
      _labels = map.map((k, v) => MapEntry(k, v.toString()));

      _interpreter = await Interpreter.fromAsset(
        'assets/models/yoga_pose_classifier.tflite',
      );

      // --- 1. CHANGE: Use streaming mode ---
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );

      // --- 2. CHANGE: Add TFLite input logging ---
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();
      debugPrint(
        'tflite input shape: ${inputTensors[0].shape}, type: ${inputTensors[0].type}',
      );
      debugPrint(
        'tflite output shape: ${outputTensors[0].shape}, type: ${outputTensors[0].type}',
      );

      setState(() {
        _isModelLoaded = true;
        _detectedPose = "Analyzing...";
      });
      debugPrint("Models loaded");
    } catch (e) {
      _showToast("Model load error: $e");
      debugPrint("Model load error: $e");
    }
  }

  // ---------- CAMERA ----------
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _isPermissionGranted = true);
      await _initializeCamera();
    } else {
      _showToast("Camera permission denied");
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showToast("No camera found");
        return;
      }

      final front = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        // --- 3. CHANGE: Prefer NV21 format ---
        imageFormatGroup: ImageFormatGroup.nv21,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _isCameraInitialized = true);

      await _controller!.startImageStream((image) {
        if (_isProcessing || !_isModelLoaded || _poseDetector == null) return;
        _isProcessing = true;
        // --- 4. CHANGE: Use verbose _processFrame ---
        // (We will replace the function below)
        _processFrame(image);
      });
    } catch (e) {
      _showToast("Camera init failed: $e");
      debugPrint("Camera init error: $e");
    }
  }

  // ---------- FRAME PROCESSING ----------
  // --- 4. REPLACEMENT: Verbose _processFrame ---
  Future<void> _processFrame(CameraImage image) async {
    try {
      debugPrint('--- frame start ---');
      debugPrint(
        'image format group: ${image.format.group}, planes: ${image.planes.length}',
      );
      for (int i = 0; i < image.planes.length; i++) {
        debugPrint(
          'plane[$i] rowStride=${image.planes[i].bytesPerRow} length=${image.planes[i].bytes.length} pixelStride=${image.planes[i].bytesPerPixel}',
        );
      }

      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        debugPrint('inputImage == null -> skipping frame');
        _isProcessing = false;
        return;
      }

      debugPrint('calling poseDetector.processImage()');
      final poses = await _poseDetector!.processImage(inputImage);
      debugPrint('poses length: ${poses.length}');

      if (poses.isEmpty) {
        if (mounted) setState(() => _detectedPose = "No Pose");
        _isProcessing = false;
        return;
      }

      final pose = poses.first;
      debugPrint('first pose landmarks count: ${pose.landmarks.length}');
      // Optional: Log a specific landmark to check if coordinates are sensible
      // debugPrint('landmark example: nose: ${poses[0].landmarks[PoseLandmarkType.nose]?.x}, ${poses[0].landmarks[PoseLandmarkType.nose]?.y}');

      final norm = _normalizePose(pose);
      if (norm == null) {
        debugPrint('normalizePose returned null');
        _isProcessing = false;
        return;
      }

      // Make sure input shape & type expected by the tflite model
      debugPrint('normalized vector length: ${norm.length}');

      final input = [norm];
      final output = [List.filled(_labels.length, 0.0)];

      try {
        _interpreter!.run(input, output);
      } catch (e) {
        debugPrint('Error running tflite interpreter: $e');
        _isProcessing = false;
        return;
      }

      final probs = (output[0] as List).cast<double>();
      debugPrint('probs: $probs');

      double maxProb = 0;
      int bestId = -1;
      for (int i = 0; i < probs.length; i++) {
        if (probs[i] > maxProb) {
          maxProb = probs[i];
          bestId = i;
        }
      }

      debugPrint('bestId: $bestId prob: $maxProb');
      if (mounted) {
        setState(() {
          _detectedPose = maxProb > 0.5
              ? (_labels[bestId.toString()] ?? "Unknown")
              : "Uncertain";
        });
      }
    } catch (e, st) {
      debugPrint('Frame processing error: $e\n$st');
    } finally {
      _isProcessing = false;
    }
  }

  // --- 5. REPLACEMENT: Robust YUV-to-NV21 converter ---
  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];

    final int ySize = planeY.bytes.length;
    // U and V planes are guaranteed to have the same new length
    final int uvSize = planeU.bytes.length;
    final nv21 = Uint8List(ySize + uvSize);

    // copy Y
    int dstIndex = 0;
    // Y plane may have rowStride > width
    for (int row = 0; row < height; row++) {
      final int rowStart = row * planeY.bytesPerRow;
      nv21.setRange(dstIndex, dstIndex + width, planeY.bytes, rowStart);
      dstIndex += width;
    }

    // interleave VU (NV21)
    // We only need to copy (height/2 * width/2) * 2 bytes
    // but the source planes can have padding (rowStride) and non-contiguous
    // pixels (pixelStride).
    final int chromaHeight = (height + 1) >> 1;
    final int chromaWidth = (width + 1) >> 1;
    final int uRowStride = planeU.bytesPerRow;
    final int vRowStride = planeV.bytesPerRow;
    final int uPixelStride = planeU.bytesPerPixel ?? 1;
    final int vPixelStride = planeV.bytesPerPixel ?? 1;

    for (int row = 0; row < chromaHeight; row++) {
      int uRowStart = row * uRowStride;
      int vRowStart = row * vRowStride;
      for (int col = 0; col < chromaWidth; col++) {
        final int uIdx = uRowStart + col * uPixelStride;
        final int vIdx = vRowStart + col * vPixelStride;

        // NV21 order: V then U
        nv21[dstIndex++] = planeV.bytes[vIdx];
        nv21[dstIndex++] = planeU.bytes[uIdx];
      }
    }

    return nv21;
  }

  // ------------------ _inputImageFromCameraImage ------------------
  // (This function was already correct, assuming the converter it calls is fixed)
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;

    // rotation
    int sensorOrientation = camera.sensorOrientation;
    if (Platform.isIOS && camera.lensDirection == CameraLensDirection.front) {
      sensorOrientation = (sensorOrientation + 180) % 360;
    }
    final rotation =
        InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation0deg;

    // format
    final inputFormat = InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputFormat == null) {
      debugPrint('InputImageFormat is null, possibly unsupported format');
      return null;
    }

    Uint8List bytes;
    InputImageFormat finalFormat;
    int bytesPerRow;

    if (image.planes.length == 3) {
      // YUV_420_888 (Android)
      // Use our robust converter
      bytes = _convertYUV420ToNV21(image);
      finalFormat = InputImageFormat.nv21;
      bytesPerRow = image.planes[0].bytesPerRow;
    } else if (image.planes.length == 1) {
      // BGRA8888 (iOS) or NV21 (Android, if lucky)
      bytes = image.planes[0].bytes;
      finalFormat = inputFormat; // Should be bgra8888 or nv21
      bytesPerRow = image.planes[0].bytesPerRow;
    } else {
      // unexpected format
      debugPrint('Unexpected image plane count: ${image.planes.length}');
      return null;
    }

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: finalFormat,
      bytesPerRow: bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  // ---------- POSE NORMALIZATION ----------
  List<double>? _normalizePose(Pose pose) {
    final lm = pose.landmarks;
    PoseLandmark? get(PoseLandmarkType t) => lm[t];

    final leftHip = get(PoseLandmarkType.leftHip);
    final rightHip = get(PoseLandmarkType.rightHip);
    final leftShoulder = get(PoseLandmarkType.leftShoulder);
    final rightShoulder = get(PoseLandmarkType.rightShoulder);

    if (leftHip == null ||
        rightHip == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return null;
    }

    // --- Center point: midpoint of hips ---
    final hx = (leftHip.x + rightHip.x) / 2;
    final hy = (leftHip.y + rightHip.y) / 2;
    final hz = (leftHip.z + rightHip.z) / 2;

    // --- Scale: torso length ---
    final sx = (leftShoulder.x + rightShoulder.x) / 2;
    final sy = (leftShoulder.y + rightShoulder.y) / 2;
    final sz = (leftShoulder.z + rightShoulder.z) / 2;

    final torso = sqrt(pow(sx - hx, 2) + pow(sy - hy, 2) + pow(sz - hz, 2));
    if (torso < 1e-6) return null; // Avoid division by zero

    final List<double> out = [];
    for (final type in PoseLandmarkType.values) {
      final l = get(type);
      if (l == null) {
        out.addAll([0.0, 0.0, 0.0, 0.0]); // x, y, z, likelihood
      } else {
        out.add((l.x - hx) / torso);
        out.add((l.y - hy) / torso);
        out.add((l.z - hz) / torso);
        out.add(l.likelihood);
      }
    }

    // Ensure we have 33 landmarks * 4 values = 132
    return out.length == 132 ? out : null;
  }

  // ---------- UI ----------
  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Live Pose Detection"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview (mirrored for front cam)
          if (_isCameraInitialized && _controller != null)
            Center(
              child: Transform.scale(
                scaleX: -1,
                child: CameraPreview(_controller!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Pose label
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _detectedPose == "No Pose" ||
                            _detectedPose == "Uncertain" ||
                            _detectedPose == "Analyzing..." ||
                            _detectedPose == "Initializing..."
                        ? Icons.info_outline
                        : Icons.self_improvement,
                    color:
                        _detectedPose.contains("Pose") &&
                            _detectedPose != "No Pose"
                        ? Colors.green
                        : _detectedPose == "No Pose"
                        ? Colors.red
                        : Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),

                  // --- THIS IS THE FIX ---
                  // We wrap the Text widget in Flexible so it can wrap
                  // to a new line instead of overflowing the container.
                  Flexible(
                    child: Text(
                      _detectedPose,
                      textAlign: TextAlign.center, // Center text if it wraps
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // --- END OF FIX ---
                ],
              ),
            ),
          ),

          // Instruction
          const Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Text(
              "Hold your pose in front of the camera",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} // Make sure this is the end of your _YogaCameraScreenState class
