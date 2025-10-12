import 'package:flutter/material.dart';

class Trainingpage extends StatefulWidget {
  const Trainingpage({super.key});

  @override
  State<Trainingpage> createState() => _TrainingpageState();
}

class _TrainingpageState extends State<Trainingpage> {
  @override
  final List<Map<String, String>> exercisePlans = [
    {
      "title": "Full Body Yoga Challenge",
      "description": "Improve flexibility and strength with this full-body plan",
    },
    {
      "title": "Beginner Kegel Power Boost",
      "description": "Strengthen pelvic muscles for better core stability",
    },
    {
      "title": "Calisthenics Yoga Flow",
      "description": "Combine bodyweight exercises and yoga postures",
    },
    {
      "title": "Lower Body Yoga Challenge",
      "description": "Focus on legs, hips, and glutes to build strength",
    },
  ];

  void openTrainingActivity(BuildContext context, String planTitle) {
    // Navigate to specific training session
    print("Opening training: $planTitle");
    // Navigator.push(...);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Workout"),
        actions: [
          TextButton(
            onPressed: () {
              print("Pro Button pressed");
            },
            child: Text(
              "Pro",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
        ],
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Goal Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      bool isCompleted = index <= 2; // Example: First 3 days completed
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isCompleted ? Colors.blue : Colors.grey[300],
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index]),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Exercise Plans",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              // Exercise Plans List
              Expanded(
                child: ListView.builder(
                  itemCount: exercisePlans.length,
                  itemBuilder: (context, index) {
                    var plan = exercisePlans[index];
                    return Card(
                      color: Colors.blue[(index + 1) * 100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          plan['title']!,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          plan['description']!,
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: Text("Start", style: TextStyle(color: Colors.blue)),
                          onPressed: () => openTrainingActivity(context, plan['title']!),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}







