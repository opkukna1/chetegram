import 'package.cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String? id;
  final String creatorId;
  final String creatorName;
  final String creatorPicUrl;
  final String subject;
  final String topic;
  final String frontText;
  final String backText;
  final String colorHex;
  final bool isPublic;
  final String imageUrl; // Image ke liye naya field
  final int likeCount;
  final Timestamp createdAt;

  Flashcard({
    this.id,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPicUrl,
    required this.subject,
    required this.topic,
    required this.frontText,
    required this.backText,
    required this.colorHex,
    required this.isPublic,
    this.imageUrl = '', // Default value
    this.likeCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPicUrl': creatorPicUrl,
      'subject': subject,
      'topic': topic,
      'frontText': frontText,
      'backText': backText,
      'colorHex': colorHex,
      'isPublic': isPublic,
      'imageUrl': imageUrl,
      'likeCount': likeCount,
      'createdAt': createdAt,
    };
  }

  factory Flashcard.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Flashcard(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      creatorPicUrl: data['creatorPicUrl'] ?? '',
      subject: data['subject'] ?? '',
      topic: data['topic'] ?? '',
      frontText: data['frontText'] ?? '',
      backText: data['backText'] ?? '',
      colorHex: data['colorHex'] ?? '#FFFFFF',
      isPublic: data['isPublic'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      likeCount: data['likeCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
