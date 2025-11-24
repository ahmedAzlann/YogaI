// lib/pages/UserDataCollectionPages/GeneratingPlanScreen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yogai/widgets/theme.dart';
import 'package:yogai/pages/HomePage.dart';

class GeneratingPlanScreen extends StatefulWidget {
  final String usertype;
  final String selectedGoal;
  final String selectedActivityLevel;
  final int selectedSessions;
  final String selectedFirstDay;
  final double weight;
  final bool isWeightInLbs;
  final int heightCm;
  final int heightFeet;
  final int heightInch;
  final bool isHeightInFt;

  const GeneratingPlanScreen({
    super.key,
    required this.usertype,
    required this.selectedGoal,
    required this.selectedActivityLevel,
    required this.selectedSessions,
    required this.selectedFirstDay,
    required this.weight,
    required this.isWeightInLbs,
    required this.heightCm,
    required this.heightFeet,
    required this.heightInch,
    required this.isHeightInFt,
  });

  @override
  State<GeneratingPlanScreen> createState() => _GeneratingPlanScreenState();
}

class _GeneratingPlanScreenState extends State<GeneratingPlanScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Timer _timer;

  final List<String> _steps = [
    "Analyzing your profile & goals",
    "Matching safe and effective yoga poses",
    "Building your personalized weekly schedule",
    "Optimizing for your body type & fitness level",
    "Finalizing your custom yoga journey",
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    // Smooth progress animation from 0 to 100%
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressController.forward();

    // Animate checkmarks one by one
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_currentStep < _steps.length) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
      }
    });

    // Navigate after completion
    Future.delayed(const Duration(seconds: 6), () {
      Get.offAll(() => const Homepage());
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatHeight() {
    if (widget.isHeightInFt) {
      return "${widget.heightFeet}ft ${widget.heightInch}in";
    } else {
      return "${widget.heightCm} cm";
    }
  }

  String _formatWeight() {
    return "${widget.weight.toStringAsFixed(1)} ${widget.isWeightInLbs ? 'lbs' : 'kg'}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
      ),
      body: Container(
        decoration: YogAITheme.onboardingGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 80),

                // Title
                Text(
                  "GENERATING YOUR\nPERSONALIZED PLAN",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: YogAITheme.darkText,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Tailoring ${widget.selectedGoal.toLowerCase()} routines just for you...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 80),

                // Animated Circular Progress
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 14,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation(
                              YogAITheme.nextButtonColor,
                            ),
                          ),
                          Text(
                            "${(_progressAnimation.value * 100).toInt()}%",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: YogAITheme.nextButtonColor,
                              shadows: [
                                Shadow(
                                  color: YogAITheme.nextButtonColor.withOpacity(
                                    0.5,
                                  ),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 80),

                // Animated Checkmark Steps
                ..._steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final text = entry.value;
                  final isActive = index < _currentStep;
                  final isCurrent = index == _currentStep;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? YogAITheme.nextButtonColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isActive
                                  ? YogAITheme.nextButtonColor
                                  : Colors.grey[400]!,
                              width: 3,
                            ),
                          ),
                          child: isActive
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : (isCurrent
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation(
                                            YogAITheme.nextButtonColor,
                                          ),
                                        ),
                                      )
                                    : null),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isActive
                                  ? YogAITheme.darkText
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const Spacer(),

                // Final Summary
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Your Profile",
                        style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${_formatHeight()} • ${_formatWeight()}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.selectedSessions} days/week • ${widget.selectedGoal}",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
