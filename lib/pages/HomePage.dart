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
    Trainingpage(),
    Discoverpage(),
    Reportpage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text(
          "YogAI",

          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black,
          ),
        ),
      ),
      body: _pages[_currentPage],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentPage = index;  // Switch page index
          });
        },
        items: [
          //training
          BottomNavigationBarItem(
            icon: Icon(Icons.lock_clock),
            label: "Training",
          ),

          //discover
          BottomNavigationBarItem(
            icon: Icon(Icons.compass_calibration),
            label: "Discover",
          ),

          //report
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Report",
          ),

          //settings
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Settings"),
        ],
      ),
    );
  }
}
