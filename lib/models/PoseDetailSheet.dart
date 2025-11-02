import 'package:flutter/material.dart';
import 'PoseModel.dart'; // wherever your PoseModel class is
import 'package:yogai/models/chewie_player_widget.dart';

class PoseDetailSheet extends StatefulWidget {
  final PoseModel pose;
  final int index;


  const PoseDetailSheet({super.key, required this.pose, required this.index});

  @override
  State<PoseDetailSheet> createState() => _PoseDetailSheetState();
}

class _PoseDetailSheetState extends State<PoseDetailSheet> {
  // move it here

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
              widget.pose.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.pose.sanskrit != null)
              Text(
                "(${widget.pose.sanskrit})",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 16),

            // Video section
            if (widget.pose.videoUrl != null && widget.pose.videoUrl!.isNotEmpty) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                child: Center(
                  child: ChewiePlayerWidget(
                    videoUrl: widget.pose.videoUrl!,
                    autoPlay: false,
                    looping: false,
                  )

                ),
              ),
              const SizedBox(height: 16),
            ],

            // Steps
            if (widget.pose.steps != null) ...[
              const Text(
                "Steps:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  widget.pose.steps.length,
                      (i) => Text(
                    "• ${widget.pose.steps[i]}",
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Benefits
            if (widget.pose.benefits != null) ...[
              const Text(
                "Benefits:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.pose.benefits.toString(),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

