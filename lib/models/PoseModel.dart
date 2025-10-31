import 'package:cloud_firestore/cloud_firestore.dart';

class PoseModel {
  final String id;
  final String name;
  final String imageUrl;
  final String? videoUrl;
  final dynamic steps;
  final dynamic benefits;
  final String? sanskrit;


  PoseModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.videoUrl,

    this.steps,
    this.benefits,
    this.sanskrit,
  });

  factory PoseModel.fromDoc(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PoseModel(
      id: doc.id,
      name: d['name'] ?? 'Unnamed',
      imageUrl: d['imageurl'] ?? '',
      videoUrl: d['videourl'],
      steps: d['steps'],
      benefits: d['benefits'],
      sanskrit: d['sanskritname'],

    );
  }
}
