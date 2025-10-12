import 'package:flutter/material.dart';

class Discoverpage extends StatefulWidget {
  const Discoverpage({super.key});

  @override
  State<Discoverpage> createState() => _DiscoverpageState();
}

class _DiscoverpageState extends State<Discoverpage> {

  final List<Map<String, String>> discoverItems = [
    {
      "title": "Benefits of Morning Yoga",
      "description": "Discover how morning yoga improves flexibility and boosts energy.",
    },
    {
      "title": "Mindfulness and Relaxation",
      "description": "Learn techniques to stay calm and focused throughout the day.",
    },
    {
      "title": "Advanced Yoga Postures",
      "description": "Take your yoga practice to the next level with these advanced postures.",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Discover"),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: discoverItems.length,
            itemBuilder: (context, index) {
              var item = discoverItems[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(
                    item['title']!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(item['description']!),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Navigate to full article or detailed view
                    print("Tapped on: ${item['title']}");
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
