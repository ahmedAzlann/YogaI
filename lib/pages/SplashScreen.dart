import 'dart:async';
import 'package:flutter/material.dart';
import '../pages/UserDataCollectionPages/GenderSelectionPage.dart';  // Next screen in flow

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
       MaterialPageRoute(builder: (context) => GenderSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
     body: Container(
       decoration: BoxDecoration(
         image: DecorationImage(
         image: AssetImage("images/womenSitting.png"),
         fit: BoxFit.cover
         )
       ),
       child: Center(
         child: Column(

           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Spacer(),
             Text("YogaAI",
         style: TextStyle(
         fontSize: 28,
           fontWeight: FontWeight.bold,
           color: Colors.white,)),
             SizedBox(
               height: 10,
             ),
         Text(
           "Harness Energy. Conquer Limits. Elevate Life.",
           style: TextStyle(
             fontSize: 16,
             color: Colors.white70,
             fontStyle: FontStyle.italic,
           )),
             SizedBox(
               height: 40,
             ),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                color: Colors.white,
                backgroundColor: Colors.grey,
              ),
            ),
             SizedBox(
               height: 40,
             )
           ],
         ),
       ),
     ),
    );

  }
}
