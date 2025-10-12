import 'package:flutter/material.dart';
import 'package:yogai/pages/HomePage.dart';

class PhysicalStatsInputScreen extends StatefulWidget {




  @override
  _PhysicalStatsInputScreenState createState() => _PhysicalStatsInputScreenState();
}

class _PhysicalStatsInputScreenState extends State<PhysicalStatsInputScreen> {
  int currentPage = 6;
  int totalPages = 6;
  double weight = 165;
  bool isWeightInLbs = true;

  int heightFeet = 5;
  int heightInch = 9;
  bool isHeightInFt = true;

  void getMyPlan() {
    print("Weight: $weight ${isWeightInLbs ? 'lbs' : 'kg'}, Height: $heightFeet ft $heightInch in");
    Navigator.pushReplacementNamed(context, '/GeneratingPlanPage'); // Navigate to Home Page after collecting data
  }
  AppBar buildProgressAppBar(BuildContext context, int currentPage, int totalPages, VoidCallback onBack, VoidCallback onSkip) {
    return AppBar(
      leading: currentPage > 0 ? IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBack,
      ) : SizedBox(width: 48), // Empty space on first page
      title: LinearProgressIndicator(
        value: (currentPage + 1) / totalPages,
        backgroundColor: Colors.grey[300],
        color: Colors.blue,
      ),
      actions: [
        TextButton(
          onPressed: onSkip,
          child: Text("Skip", style: TextStyle(color: Colors.black)),
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }


  void goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildProgressAppBar(
        context,
        currentPage,
        totalPages,
            () => Navigator.pop(context),  // Back button
            () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => Homepage()),
                (route) => false,
          );
        },  // Skip button
      ),

      body: SafeArea (
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Let us know you better", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text("Let us know you better to help boost your workout results", style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 30),

              // Weight Selection
              Text("Weight", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: [
                  ToggleButtons(
                    isSelected: [!isWeightInLbs, isWeightInLbs],
                    onPressed: (index) {
                      setState(() {
                        isWeightInLbs = index == 1;
                      });
                    },
                    children: [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('kg')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('lbs'))],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Slider(
                min: 40,
                max: 300,
                value: weight,
                divisions: 260,
                label: "${weight.toStringAsFixed(1)} ${isWeightInLbs ? 'lbs' : 'kg'}",
                onChanged: (val) {
                  setState(() {
                    weight = val;
                  });
                },
              ),
              Text("${weight.toStringAsFixed(1)} ${isWeightInLbs ? 'lbs' : 'kg'}", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

              SizedBox(height: 40),

              // Height Selection
              Text("Height", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                children: [
                  ToggleButtons(
                    isSelected: [!isHeightInFt, isHeightInFt],
                    onPressed: (index) {
                      setState(() {
                        isHeightInFt = index == 1;
                      });
                    },
                    children: [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('cm')), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('ft'))],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NumberPicker(
                    minValue: 4,
                    maxValue: 7,
                    value: heightFeet,
                    onChanged: (val) {
                      setState(() {
                        heightFeet = val;
                      });
                    },
                  ),
                  Text("ft", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  NumberPicker(
                    minValue: 0,
                    maxValue: 11,
                    value: heightInch,
                    onChanged: (val) {
                      setState(() {
                        heightInch = val;
                      });
                    },
                  ),
                  Text("in", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),

              Spacer(),

              ElevatedButton(
                onPressed: getMyPlan,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text("GET MY PLAN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A simple NumberPicker widget for selecting numbers
class NumberPicker extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;

  NumberPicker({required this.minValue, required this.maxValue, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      items: List.generate(maxValue - minValue + 1, (index) {
        int val = minValue + index;
        return DropdownMenuItem<int>(
          value: val,
          child: Text("$val", style: TextStyle(fontSize: 28)),
        );
      }),
      onChanged: (val) => onChanged(val!),
    );
  }
}
