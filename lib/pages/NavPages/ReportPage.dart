import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';

class Reportpage extends StatefulWidget {
  const Reportpage({super.key});

  @override
  State<Reportpage> createState() => _ReportpageState();
}

class _ReportpageState extends State<Reportpage> {


  @override
  Widget build(BuildContext context) {
    final titlesRef = FirebaseFirestore.instance
        .collection('user_progress')
        .doc("user1")
        .collection('titles')
        .orderBy('lastUpdated', descending: true);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Your Yoga Progress",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,backgroundColor: Colors.grey[100],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: titlesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No progress yet. Start a session!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final titles = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: titles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = titles[i];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final percent = data['completionPercent'] ?? 0;
              final lastUpdated = data['lastUpdated'] ?? '';
              final completedCount =
                  (data['completedPoses'] as List?)?.length ?? 0;

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  title: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: Colors.grey[300],
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$percent% completed • $completedCount poses done",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        "Last updated: $lastUpdated",
                        style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 18, color: Colors.grey),
                  onTap: () {
                    // Go to detail screen for this title
                   /*  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TitleDetailScreen(
                          userId: userId,
                          title: title,
                        ),
                      ),
                    );   */
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}






