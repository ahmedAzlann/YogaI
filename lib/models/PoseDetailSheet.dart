import 'package:flutter/material.dart';
import 'PoseModel.dart'; // wherever your PoseModel class is

class PoseDetailSheet extends StatelessWidget {
  final PoseModel pose;
  final int index;

  const PoseDetailSheet({super.key, required this.pose, required this.index});

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              pose.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (pose.sanskrit != null)
              Text(
                "(${pose.sanskrit})",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 16),

            if (pose.videoUrl != null && pose.videoUrl!.isNotEmpty)...[
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
            ] ,



            // Steps
            if (pose.steps != null) ...[
              const Text(
                "Steps:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  pose.steps.length,
                      (i) => Text(
                    "• ${pose.steps[i]}",
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],



            // Benefits
            if (pose.benefits != null) ...[
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                pose.benefits.toString(),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
