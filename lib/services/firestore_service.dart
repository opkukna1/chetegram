import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chetegram/models/flashcard_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- User Profile Methods ---

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
        'bio': '',
        'location': '',
        'profilePicUrl': '',
        'coverPhotoUrl': '',
        'followersCount': 0,
        'followingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  Future<DocumentSnapshot?> getUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return await _db.collection('users').doc(user.uid).get();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // --- Flashcard Methods ---

  Future<void> addFlashcard(Flashcard flashcard) async {
    try {
      await _db.collection('flashcards').add(flashcard.toMap());
    } catch (e) {
      print('Error adding flashcard: $e');
    }
  }

  Stream<QuerySnapshot> getFlashcardsStream() {
    return _db
        .collection('flashcards')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
