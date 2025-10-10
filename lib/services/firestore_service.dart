import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/models/flashcard_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  // --- User Profile Methods ---
  // ... (createUserProfile, updateUserProfile functions yahaan hain)

  // getUserProfile function ko thoda badlein taaki yeh kisi bhi user ka data la sake
  Future<DocumentSnapshot?> getUserProfile(String? uid) async {
    try {
      String userId = uid ?? _user!.uid;
      return await _db.collection('users').doc(userId).get();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // नया फंक्शन: नाम से यूज़र सर्च करने के लिए
  Future<List<QueryDocumentSnapshot>> searchUsers(String name) async {
    try {
      if (name.isEmpty) return [];
      final result = await _db
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff')
          .limit(10)
          .get();
      return result.docs;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // नया फंक्शन: किसी यूज़र को फॉलो करने के लिए
  Future<void> followUser(String otherUserId) async {
    if (_user == null) return;
    final currentUserRef = _db.collection('users').doc(_user!.uid);
    final otherUserRef = _db.collection('users').doc(otherUserId);

    final batch = _db.batch();
    // Apni following list mein doosre user ko add karein
    batch.set(currentUserRef.collection('following').doc(otherUserId), {});
    // Doosre user ki followers list mein khud ko add karein
    batch.set(otherUserRef.collection('followers').doc(_user!.uid), {});
    // Apni following count badhayein
    batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
    // Doosre user ki followers count badhayein
    batch.update(otherUserRef, {'followersCount': FieldValue.increment(1)});
    
    await batch.commit();
  }

  // नया फंक्शन: किसी यूज़र को अनफॉलो करने के लिए
  Future<void> unfollowUser(String otherUserId) async {
     if (_user == null) return;
    final currentUserRef = _db.collection('users').doc(_user!.uid);
    final otherUserRef = _db.collection('users').doc(otherUserId);

    final batch = _db.batch();
    batch.delete(currentUserRef.collection('following').doc(otherUserId));
    batch.delete(otherUserRef.collection('followers').doc(_user!.uid));
    batch.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});
    batch.update(otherUserRef, {'followersCount': FieldValue.increment(-1)});

    await batch.commit();
  }

  // नया फंक्शन: यह चेक करने के लिए कि क्या आप किसी को फॉलो कर रहे हैं
  Future<bool> isFollowing(String otherUserId) async {
    if (_user == null) return false;
    final doc = await _db.collection('users').doc(_user!.uid).collection('following').doc(otherUserId).get();
    return doc.exists;
  }

  // ... (बाकी के सभी Functions: Subjects, Tasks, Flashcards)
}
