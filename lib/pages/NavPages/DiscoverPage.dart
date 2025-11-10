import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../models/No_Internet_Screen.dart';
import '../../models/network_checker.dart';
import '../../services/detailed_card.dart';

class Discoverpage extends StatefulWidget {
  const Discoverpage({super.key});

  @override
  State<Discoverpage> createState() => _DiscoverpageState();
}

class _DiscoverpageState extends State<Discoverpage> {
  String aiMessage = "Loading your recommendations...";
  bool _hasInternet = true;
  List<String> completedPoseIds = [];
  List<Map<String, dynamic>> allPoses = [];

  String _currentTip = "Breathe. That’s the only code running perfectly right now.";
  Color _currentColor = Colors.blueAccent;

   final flows = [
    {
      'title': 'Morning Boost Flow',
      'image' : 'arms.png',
      'subtitle': '15 min • Energizing start',
      'description': 'Wake up your body with light stretches and dynamic poses to boost energy and focus for the day.',
      'gradient': [Color(0xFFFFA726), Color(0xFFFF7043)],
    },
    {
      'title': 'Challenging Yoga Poses',
      'image' : 'seated.png',
      'subtitle': '10 min • Improve posture',
      'description': 'Test your strength and balance with intermediate-level poses that build endurance and precision.',
      'gradient': [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    },
    {
      'title': 'Stress Release Flow',
      'image' : 'lback.png',
      'subtitle': '12 min • Wind down body',
      'description': 'Loosen tight muscles and calm your nerves through deep stretches and slow, mindful breathing.',
      'gradient': [Color(0xFF66BB6A), Color(0xFF43A047)],
    },
    {
      'title': 'Sleep Reset Flow',
      'image' : 'forwardbend.png',
      'subtitle': '8 min • Peaceful nights',
      'description': 'A gentle sequence to quiet the mind, relax the spine, and prepare your body for deep rest.',
      'gradient': [Color(0xFFAB47BC), Color(0xFF8E24AA)],
    },
  ];

  final List<Map<String, dynamic>> _learnTips = [
    {"text": "Yoga is not about touching your toes, it’s about what you learn on the way down.", "color": Colors.white},
    {"text": "Breathe deeper — your body listens to every inhale and exhale.", "color": Colors.white},
    {"text": "Progress in yoga isn’t flexibility, it’s awareness.", "color": Colors.white},
    {"text": "Balance isn’t something you find. It’s something you build pose by pose.", "color": Colors.white},
    {"text": "When you can’t control what’s happening, control how you breathe.", "color": Colors.white},
    {"text": "Rest days are part of the practice. The mat will wait.", "color": Colors.white},
    {"text": "You are only as young as your spine is flexible.", "color": Colors.white},
    {"text": "Meditation is not escaping the world, it’s meeting it clearly.", "color": Colors.white},
    {"text": "Stretching the body stretches the mind.", "color": Colors.white},
    {"text": "Each pose teaches patience more than posture.", "color": Colors.white},
    {"text": "Strength is calm under tension.", "color": Colors.white},
    {"text": "Your breath is your superpower. Use it when life gets loud.", "color": Colors.white},
    {"text": "Savasana is not sleep. It’s the art of conscious rest.", "color": Colors.white},
    {"text": "You don’t need perfect alignment — you need honest effort.", "color": Colors.white},
    {"text": "Your mat is a mirror. What shows up there, shows up everywhere.", "color": Colors.white},
    {"text": "Silence isn’t empty. It’s full of answers.", "color": Colors.white},
    {"text": "A strong body supports a soft heart.", "color": Colors.white},
    {"text": "Yoga doesn’t change who you are. It removes who you are not.", "color": Colors.white},
    {"text": "You can’t always calm the storm, but you can calm yourself.", "color": Colors.white},
    {"text": "The pose begins when you want to leave it.", "color": Colors.white},
    {"text": "Stillness speaks louder than any movement.", "color": Colors.white},
    {"text": "Discipline is remembering what you want most.", "color": Colors.white},
    {"text": "Flexibility follows consistency, not talent.", "color": Colors.white},
    {"text": "Your body hears everything your mind says. Be kind in both places.", "color": Colors.white},
    {"text": "Every exhale is a tiny surrender. Let go more often.", "color": Colors.white},
    {"text": "Stillness isn’t laziness — it’s your system rebooting.", "color": Colors.white},
    {"text": "Don’t rush your flexibility; even steel softens with patience.", "color": Colors.white},
    {"text": "When you hold a pose, notice what’s holding you back — it’s rarely your muscles.", "color": Colors.white},
    {"text": "The mat doesn’t care about your outfit, only your effort.", "color": Colors.white},
    {"text": "Yoga doesn’t fix life. It makes you unbothered enough to live it.", "color": Colors.white},
    {"text": "Inhale discipline, exhale doubt.", "color": Colors.white},
    {"text": "Your best pose might be the one where you finally stop comparing.", "color": Colors.white},
    {"text": "Don’t fight for balance — let it find you when you’re steady enough to notice.", "color": Colors.white},



  ];


  void _shuffleLearnCard() {
    final randomTip = (_learnTips..shuffle()).first;
    setState(() {
      _currentTip = randomTip['text'];
      _currentColor = randomTip['color'];
    });
  }



  @override
  void initState() {
    super.initState();
    _checkConnection();
    _shuffleLearnCard();
    _loadAIRecommendations();
    Connectivity().onConnectivityChanged.listen((_) {
      _checkConnection();
    });
  }

  Future<void> _loadAIRecommendations() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final userDoc = firestore.collection('user_progress').doc("user1");  //widget.userId
      final titlesSnapshot = await userDoc.collection('titles').get();

      if (titlesSnapshot.docs.isEmpty) {
        setState(() {
          aiMessage = "You haven't completed any poses yet. Start with the Morning Stretch Flow — it's a gentle wake-up call for your body and mind.";
        });
        return;
      }

      int completedCount = 0;
      int skippedCount = 0;
      List<String> completedTitles = [];
      List<String> skippedTitles = [];

      for (var doc in titlesSnapshot.docs) {
        final data = doc.data();
        final poses = (data['completedPoses'] ?? []) as List;

        for (var p in poses) {
          if (p['status'] == 'completed') {
            completedCount++;
            if (!completedTitles.contains(data['title'])) {
              completedTitles.add(data['title']);
            }
          } else if (p['status'] == 'skipped') {
            skippedCount++;
            if (!skippedTitles.contains(data['title'])) {
              skippedTitles.add(data['title']);
            }
          }
        }
      }

      String message = "";

      if (completedCount == 0 && skippedCount == 0) {
        message = "No progress yet — your mat is collecting dust. Try a short flow today.";
      } else if (completedCount > skippedCount) {
        message = "You're consistent with your practice. Based on your recent flows (${completedTitles.take(2).join(", ")}), try exploring Power or Balance flows next.";
      } else if (skippedCount > completedCount) {
        message = "You've skipped quite a few poses lately (${skippedTitles.take(2).join(", ")}). Maybe try shorter sessions like 'Quick Stretch Flow' to rebuild the habit.";
      } else {
        message = "Good balance between effort and rest. Keep mixing it up — try adding Relaxation or Meditation flows this week.";
      }

      setState(() {
        aiMessage = message;
      });
    } catch (e) {
      setState(() {
        aiMessage = "Couldn't load recommendations. Probably Mercury’s in retrograde or your internet’s gone.";
      });
    }
  }

  Widget _buildLearnCard(String text, Color color, {Key? key}) {
    return Card(
      key: key,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: color.withOpacity(0.95),
      shadowColor: color.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _checkConnection() async {
    final result = await NetworkChecker.hasConnection();
    if (mounted) {
      setState(() {
        _hasInternet = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return _hasInternet?
     SingleChildScrollView(
       physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Daily Flows",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Daily Flows Horizontal List
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: flows.length,
                  itemBuilder: (context, index) {
                    final flow = flows[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push( context, MaterialPageRoute( builder: (context) => YogaPoseDetailScreen( title: flow['title'] as String, image: 'images/${flow['image']}' ), ), );
                      },
                      child: Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: flow['gradient'] as List<Color>,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (flow['gradient'] as List<Color>)[0]
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                flow['title']! as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                flow['description']! as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                flow['subtitle']! as String,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Recommended For You",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  aiMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
// Learn & Grow Section
              // Learn & Grow Section
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Learn & Grow",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.blueAccent),
                    onPressed: _shuffleLearnCard,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildLearnCard(
                  _currentTip,
                  _currentColor,
                  key: ValueKey(_currentTip),
                ),
              ),


              // Featured Article + Video
              const SizedBox(height: 30),
              const Text(
                "Featured Article & Video",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 6,
                shadowColor: Colors.blueAccent.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: Image.asset(
                        'images/resis.png', // your thumbnail or preview image
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "How to Use Resistance Bands Effectively",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "A beginner-friendly guide to building strength and improving flexibility using resistance bands — perfect for lazy days or light workouts.",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                            label: const Text(
                              "Watch Video",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              Get.to(() => VideoPlayerScreen(videoUrl: "https://res.cloudinary.com/dztwlrj7b/video/upload/v1762075229/how_to_use_resistant_band_v4e4rs.ts"));
                            },
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    )
        : const NoInternetScreen();



  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Watch Video"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _controller.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

