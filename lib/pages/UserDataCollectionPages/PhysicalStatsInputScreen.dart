// lib/pages/UserDataCollectionPages/PhysicalStatsInputScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:yogai/pages/UserDataCollectionPages/GeneratingPlanPage.dart';
import 'package:yogai/widgets/theme.dart';

class PhysicalStatsInputScreen extends StatefulWidget {
  final String usertype;
  final String selectedGoal;
  final String selectedActivityLevel;
  final int selectedSessions;
  final String selectedFirstDay;

  const PhysicalStatsInputScreen({
    super.key,
    required this.usertype,
    required this.selectedGoal,
    required this.selectedActivityLevel,
    required this.selectedSessions,
    required this.selectedFirstDay,
  });

  @override
  State<PhysicalStatsInputScreen> createState() =>
      _PhysicalStatsInputScreenState();
}

class _PhysicalStatsInputScreenState extends State<PhysicalStatsInputScreen> {
  final int currentPage = 5;
  final int totalPages = 6;

  double weight = 65.0;
  bool isWeightInLbs = false;

  int heightCm = 170;
  int heightFeet = 5;
  int heightInch = 7;
  bool isHeightInFt = true;

  void _updateHeightFromCm() {
    final totalInches = heightCm / 2.54;
    heightFeet = (totalInches / 12).floor();
    heightInch = (totalInches % 12).round();
  }

  void _updateHeightFromFtIn() {
    final totalInches = heightFeet * 12 + heightInch;
    heightCm = (totalInches * 2.54).round();
  }

  void getMyPlan() {
    Get.to(
      () => GeneratingPlanScreen(
        usertype: widget.usertype,
        selectedGoal: widget.selectedGoal,
        selectedActivityLevel: widget.selectedActivityLevel,
        selectedSessions: widget.selectedSessions,
        selectedFirstDay: widget.selectedFirstDay,
        weight: weight,
        isWeightInLbs: isWeightInLbs,
        heightCm: heightCm,
        heightFeet: heightFeet,
        heightInch: heightInch,
        isHeightInFt: isHeightInFt,
      ),
    );
  }

  PreferredSizeWidget buildProgressAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      title: LinearProgressIndicator(
        value: (currentPage + 1) / totalPages,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation(YogAITheme.progressColor),
        minHeight: 6,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(decoration: YogAITheme.onboardingGradient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildProgressAppBar(),
      body: Container(
        decoration: YogAITheme.onboardingGradient,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Your physical stats",
                  style:
                      Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: YogAITheme.darkText,
                      ) ??
                      const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: YogAITheme.darkText,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // MAIN CONTENT — FIXED OVERFLOW
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      _buildWeightSection(),
                      const SizedBox(height: 50),
                      _buildHeightSection(),
                      const SizedBox(height: 100), // Safe space for button
                    ],
                  ),
                ),
              ),

              // GET MY PLAN Button — Always visible
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YogAITheme.nextButtonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 68),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(34),
                    ),
                    elevation: 18,
                    shadowColor: YogAITheme.nextButtonColor.withOpacity(0.6),
                  ),
                  onPressed: getMyPlan,
                  child: const Text(
                    "GET MY PLAN",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Weight",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: YogAITheme.darkText,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildToggle("kg", !isWeightInLbs, () {
              if (isWeightInLbs) setState(() => weight /= 2.20462);
              setState(() => isWeightInLbs = false);
            }),
            const SizedBox(width: 16),
            _buildToggle("lbs", isWeightInLbs, () {
              if (!isWeightInLbs) setState(() => weight *= 2.20462);
              setState(() => isWeightInLbs = true);
            }),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircleButton(
                Icons.remove,
                weight > 30
                    ? () => setState(() => weight -= isWeightInLbs ? 1 : 0.5)
                    : null,
              ),
              Column(
                children: [
                  Text(
                    weight.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: YogAITheme.nextButtonColor,
                    ),
                  ),
                  Text(
                    isWeightInLbs ? "lbs" : "kg",
                    style: TextStyle(fontSize: 22, color: Colors.grey[600]),
                  ),
                ],
              ),
              _buildCircleButton(
                Icons.add,
                weight < 300
                    ? () => setState(() => weight += isWeightInLbs ? 1 : 0.5)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Height",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: YogAITheme.darkText,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildToggle("cm", !isHeightInFt, () {
              if (isHeightInFt) _updateHeightFromFtIn();
              setState(() => isHeightInFt = false);
            }),
            const SizedBox(width: 16),
            _buildToggle("ft/in", isHeightInFt, () {
              if (!isHeightInFt) _updateHeightFromCm();
              setState(() => isHeightInFt = true);
            }),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: isHeightInFt
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNumberPicker(heightFeet, 4, 8, (v) {
                        setState(() => heightFeet = v);
                        _updateHeightFromFtIn();
                      }),
                      const SizedBox(width: 12),
                      const Text(
                        "ft",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 32),
                      _buildNumberPicker(heightInch, 0, 11, (v) {
                        setState(() => heightInch = v);
                        _updateHeightFromFtIn();
                      }),
                      const SizedBox(width: 12),
                      const Text(
                        "in",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    "$heightCm cm",
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: YogAITheme.nextButtonColor,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? YogAITheme.nextButtonColor : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: YogAITheme.nextButtonColor.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null ? YogAITheme.nextButtonColor : Colors.grey[300],
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: YogAITheme.nextButtonColor.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : Colors.grey[600],
          size: 36,
        ),
      ),
    );
  }

  Widget _buildNumberPicker(
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(28),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 40,
            color: YogAITheme.nextButtonColor,
          ),
          items: List.generate(max - min + 1, (i) {
            final val = min + i;
            return DropdownMenuItem(
              value: val,
              child: Text(
                "$val",
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: YogAITheme.nextButtonColor,
                ),
              ),
            );
          }),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }
}
