import 'package:flutter/material.dart';
import 'package:yogai/pages/NavPages/DiscoverPage.dart';
import 'package:yogai/pages/NavPages/ReportPage.dart';
import 'package:yogai/pages/NavPages/SettingsPage.dart';
import 'package:yogai/pages/NavPages/TrainingPage.dart';

import 'package:flutter/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentPage = 0;

  final _pages = [
    const Trainingpage(),
    const Discoverpage(),
    const Reportpage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF6B6B), // Your brand orange
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) => setState(() => _currentPage = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: "Training",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Settings"),
        ],
      ),
    );
  }
}
