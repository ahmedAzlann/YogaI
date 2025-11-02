import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/PoseDetailSheet.dart';
import '../models/PoseModel.dart';
import 'ReadyScreen.dart';

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
  late int currentIndex;
  final FlutterTts _tts = FlutterTts();
  late int secondsLeft;
  Timer? _timer;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    secondsLeft = 30;
    //_initVideo();
    _startTimer();
     }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);

    // await _tts.setPitch(1.0);
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

    // Add pose progress to completedPoses array
    await titleDoc.update({
      'completedPoses': FieldValue.arrayUnion([
        {
          'poseId': pose.id,
          'poseName': pose.name,
          'status': status,
          'timestamp': now,
        }
      ])
    });

    // Fetch current data to calculate completion percent
    final snapshot = await titleDoc.get();
    final completedPoses = (snapshot.data()?['completedPoses'] ?? []) as List;
    final totalCount = widget.poses.length;
    final percent = ((completedPoses.length / totalCount) * 100).round();

    // Update progress percentage
    await titleDoc.update({
      'completionPercent': percent,
      'lastUpdated': now,
    });
  }


  void _onDone() async {
    await _markProgress('completed');
    _goNext();
  }

  void _onSkip() async {
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

        if (secondsLeft == 29) {
          _speak("Start 30 seconds ${widget.poses[widget.index].name}");

          }
        // Speak countdown for last 3 seconds
        if (secondsLeft == 3 || secondsLeft == 2 || secondsLeft == 1) {
          await _speak("$secondsLeft");
        }
      }

      if (secondsLeft <= 0) {
        _timer?.cancel();
        _onDone();
      }
    });
  }

  void _goNext() {
    if (currentIndex + 1 < widget.poses.length) {
      setState(() => currentIndex++);
      _initVideo();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ReadyScreen(poses: widget.poses, index: currentIndex, userId: widget.userId,title: widget.title),
      ));
    } else {
      // session finished
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
  void _goPrevious() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _initVideo();
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ReadyScreen(poses: widget.poses, index: currentIndex, userId: widget.userId,title: widget.title),
      ));
    }
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
      builder: (context) => PoseDetailSheet(pose: pose, index: currentIndex,),
    ).then((_) {
      // resume timer when sheet is closed
      if (_isPaused) _startTimer();
    });
  }


  void _finishSession() {
    // simple completion screen or pop to list
    Navigator.popUntil(context, (route) => route.isFirst);
    // optionally show a dialog "Completed"
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = widget.poses[currentIndex];

    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child:
                      Image.network(
                      pose.imageUrl,
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                                   ),
                ),
            /*    Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ), */
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            // Top: Video or Image


            // Bottom section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Exercise name + reps
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(width: 8),
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





                    const SizedBox(height: 16),
                    Text(
                      "00:$secondsLeft",
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),


                    // DONE button (just above the bottom nav)
                    ElevatedButton.icon(
                      onPressed: _isPaused?_resumeTimer : _pauseTimer,
                      icon: Icon(_isPaused? Icons.play_arrow_rounded: Icons.pause, color: Colors.white),
                      label: Text(
                        _isPaused ? "Resume" : "Pause",
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(220, 55),
                      ),
                    ),
                    const SizedBox(height: 80),

                    // Bottom nav (Previous / Skip)

                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: _goPrevious,
                                icon: const Icon(Icons.skip_previous, color: Colors.grey,size: 34,),
                                label: const Text(
                                  "Previous",
                                  style: TextStyle(color: Colors.grey,fontSize: 20),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _onSkip,
                                icon: const Icon(Icons.skip_next, color: Colors.grey,size: 34,),
                                label: const Text(
                                  "Skip",
                                  style: TextStyle(color: Colors.grey,fontSize: 20),
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
    );

  }


}


