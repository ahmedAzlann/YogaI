import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final List<String> categories;

  FirestoreService({required this.categories});
  final CollectionReference pose = FirebaseFirestore.instance.collection("poses");

  //read from db

Stream<QuerySnapshot> getPoseStream(){
  final poseStream = pose.where('categories', arrayContainsAny: categories).snapshots();
     return poseStream;
}
}