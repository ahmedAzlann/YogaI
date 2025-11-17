import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/PoseModel.dart';
import '../services/settings_manager.dart';
import 'YogaPlayerScreen.dart';

class ReadyScreen extends StatefulWidget {
  final List<PoseModel> poses;
  final int index; // current pose index
  final String userId; // optional for progress saving
  final String title;
  const ReadyScreen({
    super.key,
    required this.title,
    required this.poses,
    required this.index,
    required this.userId,
  });

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {
  late final AudioPlayer player;
  // Change 1: Make secondsLeft nullable to handle the loading state.
  int? secondsLeft;
  Timer? _timer;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // This will now run asynchronously
    player = AudioPlayer();
    _speak("Get ready for ${widget.poses[widget.index].name}");
  }

  void _loadSettings() async {
    // Await the value first
    int loadedSeconds = await SettingsManager.getPrepTimer();
    // THEN update the state and start the timer
    setState(() {
      secondsLeft = loadedSeconds;
    });
    _startTimer();
  }

  Future<void> _speak(String text) async {
    String lang = await SettingsManager.getLanguage();
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      // We check if secondsLeft is not null, though it should be by now.
      if (secondsLeft == null) return;

      setState(() {
        secondsLeft = secondsLeft! - 1;
      });

      if (secondsLeft! <= 0) {
        _timer?.cancel();
        _goToYoga();
      }
    });
  }

  void _addSeconds(int s) {
    if (secondsLeft == null) return; // Don't add if not loaded
    setState(() {
      secondsLeft = secondsLeft! + s;
    });
    //_speak("Added $s seconds");
  }

  void _skip() async {
    _timer?.cancel();

    try {
      final player = AudioPlayer();
      await player.play(AssetSource('whistle.mp3'));
    } catch (e) {
      debugPrint("Sound play error: $e");
    }

    // delay slightly to let the sound be heard
    await Future.delayed(const Duration(milliseconds: 600));

    _goToYoga();
  }

  void _goToYoga() {
    // Check if context is still valid before navigating
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            YogaPlayerScreen(
              title: widget.title,
              poses: widget.poses,
              index: widget.index,
              userId: widget.userId,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    player.dispose(); // Dispose the player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = widget.poses[widget.index];
    return PopScope(
      canPop: false, // stops default popping
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // big image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          pose.imageUrl,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported, size: 80),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // NEW: pose index indicator
                              Text(
                                "${widget.index + 1} / ${widget.poses.length}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 8),

                              const Text(
                                "READY TO GO!",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Flexible(
                                child: Text(
                                  pose.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.visible,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Change 2: Handle the null (loading) state
                              Text(
                                secondsLeft == null
                                    ? "--:--"
                                    : secondsLeft! >= 10
                                    ? "00:$secondsLeft"
                                    : "00:0$secondsLeft",
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 30),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    // Change 3: Disable button while loading
                                    onPressed: secondsLeft == null
                                        ? null
                                        : () => _addSeconds(20),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(
                                        0.2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      "+20s",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    // Change 4: Disable button while loading
                                    onPressed: secondsLeft == null
                                        ? null
                                        : _skip,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      "Skip",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
