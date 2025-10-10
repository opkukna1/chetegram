import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // नया यूज़र बनाने पर उसकी प्रोफाइल Firestore में सेव करने का फंक्शन
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'profilePicUrl': '', // भविष्य के लिए
        'followersCount': 0,
        'followingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // भविष्य में हम यहाँ और फंक्शन जोड़ेंगे (जैसे getTasks, addFlashcard, etc.)
}
