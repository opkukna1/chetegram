import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String? id;
  final String creatorId;
  final String creatorName;
  // ... (दूसरी properties वैसी ही रहेंगी)
  final bool isPublic;
  // final String imageUrl; // यह लाइन हटा दें
  final int likeCount;
  final Timestamp createdAt;

  Flashcard({
    this.id,
    required this.creatorId,
    required this.creatorName,
    // ... (दूसरी properties वैसी ही रहेंगी)
    required this.isPublic,
    // this.imageUrl = '', // यह लाइन हटा दें
    this.likeCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      // ... (दूसरे fields)
      'isPublic': isPublic,
      // 'imageUrl': imageUrl, // यह लाइन हटा दें
      'likeCount': likeCount,
      'createdAt': createdAt,
    };
  }

  factory Flashcard.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Flashcard(
      id: doc.id,
      // ... (दूसरे fields)
      isPublic: data['isPublic'] ?? false,
      // imageUrl: data['imageUrl'] ?? '', // यह लाइन हटा दें
      likeCount: data['likeCount'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
