import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BmiCard extends StatefulWidget {
  const BmiCard({super.key});

  @override
  State<BmiCard> createState() => _BmiCardState();
}

class _BmiCardState extends State<BmiCard> {
  bool _loading = true;
  double? _bmi;
  int _feet = 5;
  int _inch = 6;
  double? _latestWeightKg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final user = await userRef.get();

    _feet = (user.data()?['heightfeet'] ?? 5) as int;
    _inch = (user.data()?['heightinch'] ?? 6) as int;

    // latest weight from logs or fallback
    final wq = await userRef
        .collection('weight_logs')
        .orderBy('date', descending: true)
        .limit(1)
        .get();
    if (wq.docs.isNotEmpty) {
      _latestWeightKg = (wq.docs.first['weightKg'] as num).toDouble();
    } else {
      final w = user.data()?['weight'];
      _latestWeightKg = w is num ? w.toDouble() : null;
    }

    _bmi = _computeBmi(_latestWeightKg, _feet, _inch);

    if (!mounted) return;
    setState(() => _loading = false);
  }

  double? _computeBmi(double? weightKg, int ft, int inch) {
    if (weightKg == null) return null;
    final totalInches = ft * 12 + inch;
    final meters = totalInches * 0.0254;
    return weightKg / (meters * meters);
  }

  Future<void> _edit() async {
    double weight = _latestWeightKg ?? 60.0;
    int feet = _feet;
    int inches = _inch;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 16),
          child: StatefulBuilder(
            builder: (context, setS) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("BMI",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const Text("Weight (kg)"),
                const SizedBox(height: 6),
                Slider(
                  min: 30,
                  max: 160,
                  divisions: 130,
                  value: weight,
                  onChanged: (v) => setS(() => weight = v),
                  label: weight.toStringAsFixed(1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${weight.toStringAsFixed(1)} kg",
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    TextButton(
                        onPressed: () {},
                        child: const Text("Adjust"))
                  ],
                ),
                const SizedBox(height: 8),
                const Text("Height"),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: feet,
                        decoration:
                        const InputDecoration(labelText: "Feet"),
                        items: List.generate(
                            8,
                                (i) => DropdownMenuItem(
                              value: i + 3,
                              child: Text("${i + 3}"),
                            )),
                        onChanged: (v) => setS(() => feet = v ?? feet),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: inches,
                        decoration:
                        const InputDecoration(labelText: "Inches"),
                        items: List.generate(
                            12,
                                (i) => DropdownMenuItem(
                              value: i,
                              child: Text("$i"),
                            )),
                        onChanged: (v) => setS(() => inches = v ?? inches),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final userRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid);
                    await userRef.set({
                      'heightfeet': feet,
                      'heightinch': inches,
                      'weight': weight,
                    }, SetOptions(merge: true));

                    _feet = feet;
                    _inch = inches;
                    _latestWeightKg = weight;
                    _bmi = _computeBmi(weight, feet, inches);

                    if (mounted) setState(() {});
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: Colors.blue),
                  child: const Text("Save",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bands = const [
      _Band(15, 16, Color(0xFF4C6EF5)),
      _Band(16, 18.5, Color(0xFF5C7CFA)),
      _Band(18.5, 25, Color(0xFF4DD0E1)), // healthy
      _Band(25, 30, Color(0xFFFFD54F)),
      _Band(30, 35, Color(0xFFFFA726)),
      _Band(35, 40, Color(0xFFE57373)),
    ];

    Widget barWithArrow() {
      return LayoutBuilder(builder: (context, c) {
        final width = c.maxWidth;
        final min = 15.0, max = 40.0;
        final v = _bmi ?? 0;
        double x = ((v - min) / (max - min)).clamp(0, 1) * width;

        return Stack(
          children: [
            Row(
              children: bands
                  .map((b) => Expanded(
                flex: ((b.end - b.start) * 10).toInt(),
                child: Container(
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: b.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ))
                  .toList(),
            ),
            if (_bmi != null)
              Positioned(
                left: x - 6,
                top: 18,
                child: const Icon(Icons.arrow_drop_down, size: 26),
              ),
          ],
        );
      });
    }

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
              child: Text("BMI",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            ElevatedButton(
              onPressed: _edit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text("Edit"),
            )
          ]),
          const SizedBox(height: 12),
          if (_loading)
            ShimmerBox(height: 80, borderRadius: 12)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _bmi == null ? "--" : _bmi!.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                barWithArrow(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("15"),
                    Text("16"),
                    Text("18.5"),
                    Text("25"),
                    Text("30"),
                    Text("35"),
                    Text("40"),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Text("Height",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text("$_feet ft $_inch in",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 18, color: Colors.black54),
                  ],
                ),
              ],
            ),
        ],
      ),
    );

    return card;
  }
}

class _Band {
  final double start, end;
  final Color color;
  const _Band(this.start, this.end, this.color);
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
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}