import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/detailed_card.dart';



class Trainingpage extends StatefulWidget {
  const Trainingpage({super.key});

  @override
  State<Trainingpage> createState() => _TrainingpageState();
}


class _TrainingpageState extends State<Trainingpage> {
  @override

  final List yogatype = ["Arm Balance Yoga Poses","Balancing Yoga Poses","Standing Yoga Poses","Seated Yoga Poses","Core","Forward Bend Yoga Poses","Twisting Yoga Poses","Hip-Opening Yoga Poses","Backbend Yoga Poses"];
  final List imgtype = ["armbalance.png","balance.png","standing.png","seated.png","core.png","forwardbend.png","twisting.png","hip-opener.png","backbend.png"];

  final List yogaparts = ["Abdominals","Arms","Hamstrings","Hips","Knees","Lower Back","Legs","Upper Back","Lungs"];
  final List imgparts = ["abdominals.png","arms.png","hamsrings.png","hips.png","knees.png","lback.png","legs.png","uback.png","lungs.png"];

  final List yogabenefis =["Yoga Poses For Anxiety","Yoga Poses For Back Pain","Yoga Poses For Calm","Yoga Poses For Digestion","Yoga Poses For Flexibility","Yoga Poses For Headaches","Yoga For High Blood Pressure","Yoga For Neck Pain","Yoga Poses For Sciatica"];
  final List imgbenefis =["anxiety.png","backpain.png","calm.png","digestion.png","flexibility.png","headache.png","bp.png","neckpain.png","scia.png"];


  void openTrainingActivity(BuildContext context, String planTitle) {
    // Navigate to specific training session
    print("Opening training: $planTitle");
    // Navigator.push(...);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(child:
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          children: [
            // search bar
            TextField(
             decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
               hintText:"Find your flow today",
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)
               ),
               filled: true,
               fillColor: Colors.grey[200],
             )
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Yoga By Type",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                TextButton(onPressed: (){},
                  child: Text("Explore",style: TextStyle(fontSize: 12),)
                  ,),
              ],
            ),

            SizedBox(
              height: 160, // height of the card
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // horizontal scroll
                itemCount: yogatype.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YogaPoseDetailScreen(
                              title: yogatype[index],
                              image: 'images/${imgtype[index]}',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Image
                              Image.asset(
                                'images/${imgtype[index]}',
                                height: 160,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                      
                              // Grey overlay for text visibility
                              Container(
                                height: 160,
                                width: 200,
                                color: Colors.black.withOpacity(0.3),
                              ),
                      
                              // Text at the bottom
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: Text(
                                  yogatype[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Yoga By Anatomy ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                TextButton(onPressed: (){},
                  child: Text("Explore",style: TextStyle(fontSize: 12),)
                  ,),
              ],
            ),

            SizedBox(
              height: 160,
              child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: yogaparts.length ,itemBuilder: (context,index){
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => YogaPoseDetailScreen(
                          title: yogaparts[index],
                          image: 'images/${imgparts[index]}',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)
                    ),
                    elevation: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image.asset(
                            'images/${imgparts[index]}',
                            height: 160,
                            width: 200,
                            fit: BoxFit.cover,),
                          Container(
                            height: 160,
                            width: 200,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          Positioned( bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              yogaparts[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ), )
                        ],
                      ),
                    ),
                  ),
                ),
              );
              }),
            ),
        
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Yoga By Benefits ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                TextButton(onPressed: (){},
                  child: Text("Explore",style: TextStyle(fontSize: 12),)
                  ,),
              ],
            ),
        
            SizedBox(
              height: 160,
              child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: yogaparts.length ,itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YogaPoseDetailScreen(
                            title: yogabenefis[index],
                            image: 'images/${imgbenefis[index]}',
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)
                      ),
                      elevation: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.asset(
                              'images/${imgbenefis[index]}',
                              height: 160,
                              width: 200,
                              fit: BoxFit.cover,),
                            Container(
                              height: 160,
                              width: 200,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            Positioned( bottom: 10,
                              left: 10,
                              right: 10,
                              child: Text(
                                yogabenefis[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ), )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

          /*  ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('test')
                    .add({'time': DateTime.now().toString()});
              },
              child: const Text('Add test document'),
            ),
*/
          ],
          ),
        ),
        ),
      )
    );
  }
}






