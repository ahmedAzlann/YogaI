import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/No_Internet_Screen.dart';
import '../../models/network_checker.dart';
import '../../services/detailed_card.dart';


class Reportpage extends StatefulWidget {
  const Reportpage({super.key});

  @override
  State<Reportpage> createState() => _ReportpageState();
}

class _ReportpageState extends State<Reportpage> {
  bool _hasInternet = true;
  late String uid;

  Future<void> _checkConnection() async {
    final result = await NetworkChecker.hasConnection();
    if (mounted) {
      setState(() {
        _hasInternet = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    Connectivity().onConnectivityChanged.listen((_) {
      _checkConnection();
    });
  }

  // confirmation dialog for deletion
  Future<bool> _showDeleteDialog(BuildContext context, String docId) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          title: const Text("Delete Progress?"),
          content: const Text(
            "Are you sure you want to delete this progress record? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('user_progress')
                      .doc(uid)
                      .collection('titles')
                      .doc(docId)
                      .delete();
                  Navigator.of(context).pop(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Progress deleted successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                        Text('Error deleting progress: ${e.toString()}')),
                  );
                }
              },
              child: const Text("Delete",style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final titlesRef = FirebaseFirestore.instance
        .collection('user_progress')
        .doc(uid)
        .collection('titles')
        .orderBy('lastUpdated', descending: true);

    return _hasInternet
        ? Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Your Yoga Progress",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
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
              final lastUpdatedRaw = data['lastUpdated'] ?? '';
              final completedCount =
                  (data['completedPoses'] as List?)?.length ?? 0;
              final imagePath = 'images/default_yoga.png'; // fallback image if missing

              // Parse and format date
              String formattedDate = 'Unknown';
              if (lastUpdatedRaw is String &&
                  lastUpdatedRaw.isNotEmpty) {
                try {
                  final parsedDate = DateTime.parse(lastUpdatedRaw);

                  String getDaySuffix(int day) {
                    if (day >= 11 && day <= 13) return 'th';
                    switch (day % 10) {
                      case 1:
                        return 'st';
                      case 2:
                        return 'nd';
                      case 3:
                        return 'rd';
                      default:
                        return 'th';
                    }
                  }

                  final day = parsedDate.day;
                  final suffix = getDaySuffix(day);
                  formattedDate =
                  "$day$suffix ${DateFormat('MMM yyyy').format(parsedDate)}";
                } catch (e) {
                  formattedDate = 'Invalid date';
                }
              }

              // 🧩 Dismissible wrapper with tap navigation
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Dismissible(
                  key: Key(doc.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete,
                        color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (direction) async {
                    return await _showDeleteDialog(context, doc.id);
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),

                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
                            style:
                            const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "Last updated: $formattedDate",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YogaPoseDetailScreen(
                              title: title,
                              image: imagePath,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    )
        : const NoInternetScreen();
  }
}
