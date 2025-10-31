import 'package:cloud_firestore/cloud_firestore.dart';
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

  const YogaPlayerScreen({
    super.key,
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
  late int secondsLeft;
  Timer? _timer;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    secondsLeft = 30;
    _initVideo();
    _startTimer();

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
    final col = FirebaseFirestore.instance.collection('user_progress');

    final docRef = col.doc(userId); // one doc per user-session (you can change)
    final now = DateTime.now().toIso8601String();

    await docRef.set({
      'userId': userId,
      'lastUpdated': now,
      // keep other meta if needed
    }, SetOptions(merge: true));

    await docRef.update({
      'completedPoses': FieldValue.arrayUnion([
        {
          'poseId': pose.id,
          'poseName': pose.name,
          'status': status,
          'timestamp': now,
        }
      ])
    });

    // update percentage (simple calculation)

    final completedCount = currentIndex;
    final totalCount = widget.poses.length;
    final percent = (completedCount+1 / totalCount * 100).round();
    await docRef.update({'completionPercent': percent});

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
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if(!_isPaused){
        setState(() {
          secondsLeft--;
        });
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
        builder: (_) => ReadyScreen(poses: widget.poses, index: currentIndex, userId: widget.userId),
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
        builder: (_) => ReadyScreen(poses: widget.poses, index: currentIndex, userId: widget.userId),
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
            // Top: Video or Image
            if (_videoController != null && _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            else
              Image.network(
                pose.imageUrl,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

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
                      children: [
                        Text(
                          pose.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap:(){ _showPoseInfo(pose);},
                          child: const Icon(Icons.help_outline, color: Colors.blueAccent, size: 26),
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


