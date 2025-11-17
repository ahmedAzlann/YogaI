import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/PoseDetailSheet.dart';
import '../models/PoseModel.dart';
import '../services/settings_manager.dart';
import 'ReadyScreen.dart';
import 'UserDataCollectionPages/completed_session_page.dart';
import 'YogaCameraScreen.dart';

class YogaPlayerScreen extends StatefulWidget {
  final List<PoseModel> poses;
  final int index;
  final String userId;
  final String title;
  const YogaPlayerScreen({
    super.key,
    required this.title,
    required this.poses,
    required this.index,
    required this.userId,
  });

  @override
  State<YogaPlayerScreen> createState() => _YogaPlayerScreenState();
}

class _YogaPlayerScreenState extends State<YogaPlayerScreen> {
  bool _isPaused = false;
  late final player;
  late int currentIndex;
  final FlutterTts _tts = FlutterTts();
  late int secondsLeft;
  late int middle;
  late int og;
  late int announce;
  Timer? _timer;
  VideoPlayerController? _videoController;
  late bool voiceGuide;
  late bool coachTips;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    player = AudioCache();
    _loadSettings();
  }

  void _loadSettings() async {
    secondsLeft = await SettingsManager.getRestTimer();
    voiceGuide = await SettingsManager.getVoiceGuide();
    coachTips = await SettingsManager.getCoachTips();

    og = secondsLeft;
    middle = secondsLeft ~/ 2; // correct
    announce = secondsLeft - 2;

    setState(() {});
    _startTimer();
  }

  Future<void> _speak(String text) async {
    String lang = await SettingsManager.getLanguage();
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  void _initVideo() {
    final videoUrl = widget.poses[currentIndex].videoUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
        });
    }
  }

  Future<void> _markProgress(String status) async {
    final pose = widget.poses[currentIndex];
    final userId = widget.userId;
    final title = widget.title;

    final firestore = FirebaseFirestore.instance;
    final userDoc = firestore.collection('user_progress').doc(userId);
    final titleDoc = userDoc.collection('titles').doc(title);

    final now = DateTime.now().toIso8601String();

    // Add/update the title document for this user
    await titleDoc.set({
      'userId': userId,
      'title': title,
      'lastUpdated': now,
    }, SetOptions(merge: true));

    // Fetch existing data
    final snapshot = await titleDoc.get();
    final existing = (snapshot.data()?['completedPoses'] ?? []) as List;

    // Check if this pose is already recorded
    final alreadyDone = existing.any((p) => p['poseId'] == pose.id);

    // Only add new poses if not already logged
    if (!alreadyDone) {
      await titleDoc.update({
        'completedPoses': FieldValue.arrayUnion([
          {
            'poseId': pose.id,
            'poseName': pose.name,
            'status': status,
            'timestamp': now,
          },
        ]),
      });
    }

    // Fetch updated snapshot to calculate completion percent
    final updatedSnapshot = await titleDoc.get();
    final completedPoses =
        (updatedSnapshot.data()?['completedPoses'] ?? []) as List;
    final totalCount = widget.poses.isEmpty ? 1 : widget.poses.length;
    final percent = ((completedPoses.length / totalCount) * 100).round();

    // Update progress percentage
    await titleDoc.update({'completionPercent': percent, 'lastUpdated': now});
  }

  void _onDone() async {
    await _markProgress('completed');
    _goNext();
  }

  Future<void> _onSkip() async {
    await _tts.stop();

    // play bell sound
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('hectorbell.mp3'));
    } catch (e) {
      debugPrint("Sound play error: $e");
    }

    // slight delay
    await Future.delayed(const Duration(milliseconds: 400));

    await _markProgress('skipped');
    _goNext();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!_isPaused) {
        setState(() {
          secondsLeft--;
        });

        // ✅ Start announcement
        if (secondsLeft == announce) {
          if (voiceGuide) {
            _speak("Start $og seconds ${widget.poses[currentIndex].name}");
          }
        }

        // ✅ Coach tips halfway
        if (secondsLeft == middle) {
          if (coachTips) {
            _speak("This exercise ${widget.poses[currentIndex].benefits}");
          }
        }

        // ✅ Last 3 seconds countdown only if voiceGuide enabled
        if (voiceGuide &&
            (secondsLeft == 3 || secondsLeft == 2 || secondsLeft == 1)) {
          await _speak("$secondsLeft");
        }
      }

      if (secondsLeft <= 0) {
        _timer?.cancel();
        try {
          final player = AudioPlayer();
          await player.play(AssetSource('hectorbell.mp3'));
        } catch (e) {
          debugPrint("Sound play error: $e");
        }

        await Future.delayed(const Duration(milliseconds: 200));
        _onDone();
      }
    });
  }

  void _goNext() async {
    await _markProgress('completed');

    if (currentIndex + 1 < widget.poses.length) {
      setState(() => currentIndex++);

      // optional: play whistle or transition sound here

      // delay slightly for the sound to register
      //await Future.delayed(const Duration(milliseconds: 400));

      // smooth animated transition to ReadyScreen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) => ReadyScreen(
            poses: widget.poses,
            index: currentIndex,
            userId: widget.userId,
            title: widget.title,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(0.2, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
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
    } else {
      _finishSession();
    }
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _goPrevious() async {
    await _tts.stop();

    try {
      final player = AudioPlayer();
      await player.play(AssetSource('hectorbell.mp3'));
    } catch (e) {
      debugPrint("Sound play error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (currentIndex <= 0) return;

    setState(() => currentIndex--);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 700),
        pageBuilder: (_, animation, __) => ReadyScreen(
          poses: widget.poses,
          index: currentIndex,
          userId: widget.userId,
          title: widget.title,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(-0.2, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _quitOption(BuildContext context, String text) {
    return InkWell(
      onTap: () => Navigator.pop(context, true),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showPoseInfo(PoseModel pose) {
    _pauseTimer(); // <-- pause the timer before opening sheet

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => PoseDetailSheet(pose: pose, index: currentIndex),
    ).then((_) {
      // resume timer when sheet is closed
      if (_isPaused) _startTimer();
    });
  }

  Future<void> _showbox() async {
    _pauseTimer();

    final shouldQuit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blue.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 26),
              onPressed: () => Navigator.pop(context, false),
              tooltip: 'Cancel',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _quitOption(context, 'Just take a look'),
            const SizedBox(height: 10),
            _quitOption(context, 'Too hard'),
            const SizedBox(height: 10),
            _quitOption(context, "Don't know how to do it"),
          ],
        ),
      ),
    );

    if (shouldQuit == true) {
      Navigator.pop(context);
    }
  }

  Future<void> logDailyActivity() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('activity_logs')
        .doc(todayId);

    await ref.set({
      'done': true,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _finishSession() async {
    await logDailyActivity();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionCompletedScreen(
          programName: widget.title,
          exerciseCount: widget.poses.length,
          calories: 0,
          time: Duration.zero,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = widget.poses[currentIndex];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _showbox();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.network(
                      pose.imageUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _showbox,
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Progress Indicator
                      Text(
                        "${currentIndex + 1} / ${widget.poses.length}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Pose Name + Info Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              pose.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showPoseInfo(pose),
                            child: const Icon(
                              Icons.help_outline,
                              color: Colors.blueAccent,
                              size: 26,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Timer
                      Text(
                        secondsLeft >= 10
                            ? "00:$secondsLeft"
                            : "00:0$secondsLeft",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Pause/Resume Button
                      ElevatedButton.icon(
                        onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                        icon: Icon(
                          _isPaused ? Icons.play_arrow_rounded : Icons.pause,
                          color: Colors.white,
                          size: 30,
                        ),
                        label: Text(
                          _isPaused ? "Resume" : "Pause",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 30,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      ),

                      const SizedBox(height: 70),

                      // Navigation Row
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Previous
                            TextButton.icon(
                              onPressed: _goPrevious,
                              icon: const Icon(
                                Icons.skip_previous_rounded,
                                color: Colors.grey,
                                size: 34,
                              ),
                              label: const Text(
                                "Previous",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Skip
                            TextButton.icon(
                              onPressed: _onSkip,
                              icon: const Icon(
                                Icons.skip_next_rounded,
                                color: Colors.grey,
                                size: 34,
                              ),
                              label: const Text(
                                "Skip",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // CAMERA BUTTON - CORRECTLY PLACED
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const YogaCameraScreen()),
            );
          },
          backgroundColor: Colors.purple,
          elevation: 6,
          tooltip: 'Live Pose Detection',
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
