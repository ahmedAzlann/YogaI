import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/PoseModel.dart';
import '../pages/ReadyScreen.dart';
import 'firebase_service.dart';

class YogaPoseDetailScreen extends StatefulWidget {
  final String title;
  final String image;

  const YogaPoseDetailScreen({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  State<YogaPoseDetailScreen> createState() => _YogaPoseDetailScreenState();
}

class _YogaPoseDetailScreenState extends State<YogaPoseDetailScreen> {
  late List<String> categories;

  void initcategory() {
    switch (widget.title) {
      case "Arm Balance Yoga Poses":
        categories = ["arm", "balance"];
        break;
      case "Balancing Yoga Poses":
        categories = ["balance"];
        break;
      case "Standing Yoga Poses":
        categories = ["Standing"];
        break;
      case "Seated Yoga Poses":
        categories = ["Sitting"];
        break;
      case "Core":
        categories = ["core"];
        break;
      case "Forward Bend Yoga Poses":
        categories = ["forwardbend"];
        break;
      case "Twisting Yoga Poses":
        categories = ["twisting"];
        break;
      case "Hip-Opening Yoga Poses":
        categories = ["hip opener"];
        break;
      case "Backbend Yoga Poses":
        categories = ["backbend", "Sitting"];
        break;
      case "Abdominals":
        categories = ["twisting", "stretching"];
        break;
      case "Arms":
        categories = ["arm"];
        break;
      case "Hamstrings":
        categories = ["stretching", "sitting"];
        break;
      case "Hips":
        categories = ["twisting", "hip opener"];
        break;
      case "Knees":
        categories = ["knee"];
        break;
      case "Lower Back":
        categories = ["core", "hip opener"];
        break;
      case "Legs":
        categories = ["backbend", "stretching"];
        break;
      case "Upper Back":
        categories = ["twisting", "hip opener"];
        break;
      case "Lungs":
        categories = ["breathing", "stretching", "twisting"];
        break;
      case "Yoga Poses For Anxiety":
        categories = ["stretching", "balance"];
        break;
      case "Yoga Poses For Back Pain":
        categories = ["stretching", "forwardbend"];
        break;
      case "Yoga Poses For Calm":
        categories = ["balance", "breathing"];
        break;
      case "Yoga Poses For Digestion":
        categories = ["backbend", "twisting"];
        break;
      case "Yoga Poses For Flexibility":
        categories = ["stretching", "sitting"];
        break;
      case "Yoga Poses For Headaches":
        categories = ["forwardbend", "breathing"];
        break;
      case "Yoga For High Blood Pressure":
        categories = ["standing", "core"];
        break;
      case "Yoga For Neck Pain":
        categories = ["stretching", "core"];
        break;
      case "Yoga Poses For Sciatica":
        categories = ["sitting", "core", "backbend"];
        break;
      default:
        categories = [];
    }
  }

  @override
  void initState() {
    super.initState();
    initcategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Image.asset(
                    widget.image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
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

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirestoreService(categories: categories).getPoseStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No poses found'));
                  }

                  final poses = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Info boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoBox("Duration", "${((poses.length * 30)/60).toInt()} mins"),
                          _infoBox("Exercises", poses.length.toString()),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Text("Exercises", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                     // const SizedBox(height: 12),

                  ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: poses.length,
                  itemBuilder: (context, index) {
                  final doc = poses[index];
                  final data = doc.data() as Map<String, dynamic>? ?? {};

                  final name = data['name'] ?? 'Unnamed Pose';
                  final imageUrl = data['imageurl'] ?? '';
                  final sanskritName = data['sanskritname'] ?? '';
                  final benefits = data['benefits'] ?? 'No benefits listed';
                  final caution = data['caution'] ?? 'No cautions listed';
                  final steps = data['steps'] ?? [];
                  final videoUrl = data['videourl'] ?? ''; // optional, add in Firestore if needed

                  return InkWell(
                  onTap: () {
                  showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                  return DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.75,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Center(
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl.isNotEmpty
                  ? Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  )
                      : const Icon(Icons.image_not_supported, size: 100),
                  ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                  name,
                  style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  ),
                  ),
                  if (sanskritName.isNotEmpty)
                  Text(
                  sanskritName,
                  style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  ),
                  ),
                  const SizedBox(height: 16),
                  if (videoUrl.isNotEmpty)
                  Container(
                  height: 200,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                  ),
                  child: Center(
                  child: IconButton(
                  icon: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.blueAccent,
                  size: 64,
                  ),
                  onPressed: () {
                  // open video URL
                  },
                  ),
                  ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                  "Benefits",
                  style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  ),
                  ),
                  Text(
                  benefits,
                  style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                  "Caution",
                  style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  ),
                  ),
                  Text(
                  caution,
                  style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                    Text(
                      "Steps",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        steps.length,
                            (i) => Text(
                          "• ${steps[i]}",
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  ],
                  ),
                  ),
                  );
                  },
                  );
                  },
                  child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                  children: [
                  ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                  ? Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  )
                      : const Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey,
                  ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                  name,
                  style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                  "00:30 secs",
                  style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  ),
                  ),
                  ],
                  ),
                  ),
                  const Icon(
                  Icons.play_circle_outline,
                  color: Colors.blueAccent,
                  size: 28,
                  ),
                  ],
                  ),
                  ),
                  ),
                  );
                  },
                  ),



                  const SizedBox(height: 16),



                           SizedBox(
                             width:double.infinity,
                             child: ElevatedButton(
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.blueAccent[200],

                                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                               ),
                               onPressed: () {
                                 final poseModels = poses.map((d) => PoseModel.fromDoc(d)).toList();
                                 Navigator.push(context, MaterialPageRoute(
                                   builder: (_) => ReadyScreen(poses: poseModels, index: 0, userId: "user1"), //add poses.length;
                                 ));

                               },
                               child: const Text("Start", style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold)),
                             ),
                           ),







                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
         BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
