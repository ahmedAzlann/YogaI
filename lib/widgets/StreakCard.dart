import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  int _streak = 0;
  int _best = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Best streak
    final userSnap = await userRef.get();
    _best = userSnap.data()?['bestStreak'] ?? 0;

    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));

    final logs = await userRef
        .collection('activity_logs')
        .where("timestamp", isGreaterThanOrEqualTo: from)
        .orderBy("timestamp", descending: true)
        .get();

    final logDates = logs.docs
        .where((d) => d['timestamp'] != null)
        .map((d) => (d['timestamp'] as Timestamp).toDate())
        .toList();

    final logSet = logDates
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toSet();

    int streak = 0;
    DateTime day = DateTime(now.year, now.month, now.day);

    while (logSet.contains(DateFormat('yyyy-MM-dd').format(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    if (streak > _best) {
      await userRef.set({'bestStreak': streak}, SetOptions(merge: true));
      _best = streak;
    }

    if (!mounted) return;
    setState(() {
      _streak = streak;
      _loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ShimmerBox(height: 100, borderRadius: 18);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Day Streak",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _streak.toString(),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Personal Best",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  text: _best.toString(),
                  style: const TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.w800),
                  children: const [
                    TextSpan(
                      text: " day",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double height;
  final double borderRadius;
  const ShimmerBox({super.key, required this.height, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
