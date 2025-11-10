import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightCard extends StatefulWidget {
  const WeightCard({super.key});

  @override
  State<WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<WeightCard> {
  bool _loading = true;
  List<_WeightPoint> _points = [];
  double? _current;
  double? _min;
  double? _max;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final q = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('weight_logs')
        .orderBy('date', descending: false)
        .limit(30)
        .get();

    final pts = q.docs
        .map((d) =>
        _WeightPoint((d['date'] as Timestamp).toDate(), (d['weightKg'] as num).toDouble()))
        .toList();

    if (pts.isNotEmpty) {
      _current = pts.last.value;
      _min = pts.map((e) => e.value).reduce((a, b) => a < b ? a : b);
      _max = pts.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    }

    if (!mounted) return;
    setState(() {
      _points = pts;
      _loading = false;
    });
  }



  Future<void> _logWeight() async {
    final controller = TextEditingController(
        text: _current?.toStringAsFixed(1) ?? "");
    DateTime date = DateTime.now();

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Log Weight",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Date"),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        date = picked;
                      }
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final v = double.tryParse(controller.text.trim());
                  if (v == null) {
                    Navigator.pop(context);
                    return;
                  }
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  final ref = FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('weight_logs');
                  await ref.add({
                    'date': DateTime(date.year, date.month, date.day),
                    'weightKg': v,
                  });
                  if (mounted) Navigator.pop(context);
                  await _load();
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text("Weight",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            ElevatedButton(
              onPressed: _logWeight,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text("Log"),
            )
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current",
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                        _current == null ? "--" : "${_current!.toStringAsFixed(1)} kg",
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ]),
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatRow(label: "Heaviest", value: _max),
                    const SizedBox(height: 6),
                    _StatRow(label: "Lightest", value: _min),
                  ]),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _loading
                ? ShimmerBox(height: 200, borderRadius: 12)
                : (_points.isEmpty
                ? const Center(child: Text("No data yet"))
                : LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: ((_max ?? 0) - (_min ?? 0)) / 4.0 > 0
                          ? ((_max! - _min!) / 4.0)
                          : 1,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (_points.length / 6).ceilToDouble(),
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= _points.length) {
                          return const SizedBox.shrink();
                        }
                        final d = _points[i].date;
                        return Text("${d.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    spots: List.generate(_points.length,
                            (i) => FlSpot(i.toDouble(), _points[i].value)),
                    color: Colors.blue,
                    barWidth: 3,
                  ),
                ],
              ),
            )),
          ),
        ],
      ),
    );

    return card;
  }
}

class _WeightPoint {
  final DateTime date;
  final double value;
  _WeightPoint(this.date, this.value);
}

class _StatRow extends StatelessWidget {
  final String label;
  final double? value;
  const _StatRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label,
          style: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w600)),
      const SizedBox(width: 8),
      Text(value == null ? "--" : value!.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800)),
    ],
  );
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
