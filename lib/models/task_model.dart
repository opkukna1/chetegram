import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id; // Firestore Document ID के लिए String
  final String subject;
  final String topic;
  int readingStage;
  Timestamp nextRevisionDate; // DateTime की जगह Timestamp
  String status;

  Task({
    this.id,
    required this.subject,
    required this.topic,
    this.readingStage = 1,
    required this.nextRevisionDate,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'topic': topic,
      'readingStage': readingStage,
      'nextRevisionDate': nextRevisionDate,
      'status': status,
    };
  }

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      subject: data['subject'] ?? '',
      topic: data['topic'] ?? '',
      readingStage: data['readingStage'] ?? 1,
      nextRevisionDate: data['nextRevisionDate'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
    );
  }
}
