import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/models/flashcard_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

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
      if (_user == null) return null;
      return await _db.collection('users').doc(_user!.uid).get();
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

  // --- Subject/Topic Methods ---

  Future<List<String>> getSubjects() async {
    try {
      final snapshot = await _db.collection('subjects').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<String>> getTopicsForSubject(String subject) async {
    try {
      final snapshot = await _db.collection('subjects').doc(subject).collection('topics').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // --- Task Methods ---

  CollectionReference get _tasksCollection {
    if (_user == null) throw Exception('User not logged in');
    return _db.collection('users').doc(_user!.uid).collection('tasks');
  }

  Future<void> addTask(Task task) async {
    try {
      await _tasksCollection.add(task.toMap());
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toMap());
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Stream<QuerySnapshot> getTasksStream() {
    return _tasksCollection.orderBy('nextRevisionDate', descending: false).snapshots();
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
