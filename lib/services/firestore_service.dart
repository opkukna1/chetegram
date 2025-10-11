import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/models/timetable_model.dart';
import 'package:chetegram/models/time_slot_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  // --- User Profile & Follow Methods ---

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

  Future<DocumentSnapshot?> getUserProfile(String? uid) async {
    try {
      String userId = uid ?? _user!.uid;
      return await _db.collection('users').doc(userId).get();
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

  Future<void> followUser(String otherUserId) async {
    if (_user == null) return;
    final currentUserRef = _db.collection('users').doc(_user!.uid);
    final otherUserRef = _db.collection('users').doc(otherUserId);

    final batch = _db.batch();
    batch.set(currentUserRef.collection('following').doc(otherUserId), {});
    batch.set(otherUserRef.collection('followers').doc(_user!.uid), {});
    batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
    batch.update(otherUserRef, {'followersCount': FieldValue.increment(1)});
    
    await batch.commit();
  }

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

  Future<bool> isFollowing(String otherUserId) async {
    if (_user == null) return false;
    final doc = await _db.collection('users').doc(_user!.uid).collection('following').doc(otherUserId).get();
    return doc.exists;
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
  
  Future<bool> doesTaskExist(String subject, String topic) async {
    if (_user == null) return true; // Prevent adding if not logged in
    
    final query = await _tasksCollection
        .where('subject', isEqualTo: subject)
        .where('topic', isEqualTo: topic)
        .limit(1)
        .get();
        
    return query.docs.isNotEmpty;
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
    if (_user == null) return Stream.empty();
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

  Stream<QuerySnapshot<Map<String, dynamic>>> getFeedFlashcards() async* {
    if (_user == null) {
      yield* Stream.empty();
      return;
    }

    final followingSnapshot = await _db.collection('users').doc(_user!.uid).collection('following').get();
    final followingIds = followingSnapshot.docs.map((doc) => doc.id).toList();

    if (followingIds.isEmpty) {
      yield* Stream.empty();
      return;
    }

    yield* _db
        .collection('flashcards')
        .where('creatorId', whereIn: followingIds)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecommendedFlashcards() {
    return _db
        .collection('flashcards')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }
  
  Future<void> toggleLike(String flashcardId, bool isCurrentlyLiked) async {
    if (_user == null) return;
    
    final flashcardRef = _db.collection('flashcards').doc(flashcardId);
    final likesRef = flashcardRef.collection('likes').doc(_user!.uid);

    if (isCurrentlyLiked) {
      await likesRef.delete();
      await flashcardRef.update({'likeCount': FieldValue.increment(-1)});
    } else {
      await likesRef.set({'likedAt': FieldValue.serverTimestamp()});
      await flashcardRef.update({'likeCount': FieldValue.increment(1)});
    }
  }

  Stream<bool> checkIfLiked(String flashcardId) {
    if (_user == null) return Stream.value(false);
    return _db
        .collection('flashcards')
        .doc(flashcardId)
        .collection('likes')
        .doc(_user!.uid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  // --- TimeTable Methods ---

  CollectionReference get _timetablesCollection {
    if (_user == null) throw Exception('User not logged in');
    return _db.collection('users').doc(_user!.uid).collection('timetables');
  }

  Future<void> addTimeTable(TimeTableModel timetable, List<TimeSlotModel> slots) async {
    try {
      DocumentReference timetableRef = await _timetablesCollection.add(timetable.toMap());
      for (var slot in slots) {
        await timetableRef.collection('slots').add(slot.toMap());
      }
    } catch (e) {
      print('Error adding timetable: $e');
    }
  }

  Stream<List<TimeTableModel>> getTimeTablesStream() {
    if (_user == null) return Stream.value([]);
    return _timetablesCollection.snapshots().asyncMap((snapshot) async {
      List<TimeTableModel> timetables = [];
      for (var doc in snapshot.docs) {
        final timetable = TimeTableModel.fromFirestore(doc);
        final slotsSnapshot = await doc.reference.collection('slots').get();
        final slots = slotsSnapshot.docs
            .map((slotDoc) => TimeSlotModel.fromFirestore(slotDoc.data(), slotDoc.id))
            .toList();
        timetables.add(TimeTableModel(id: timetable.id, title: timetable.title, slots: slots));
      }
      return timetables;
    });
  }

  Future<void> deleteTimeTable(String timetableId) async {
    try {
      await _timetablesCollection.doc(timetableId).delete();
    } catch (e) {
      print('Error deleting timetable: $e');
    }
  }

  // --- Advanced Analytics Methods ---

  Future<Map<String, double>> getTasksCountBySubject() async {
    if (_user == null) return {};

    try {
      final snapshot = await _tasksCollection.get();
      final tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      
      final Map<String, double> subjectCount = {};
      for (var task in tasks) {
        subjectCount.update(
          task.subject,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      return subjectCount;
    } catch (e) {
      print('Error getting tasks count by subject: $e');
      return {};
    }
  }

  Future<void> addRevisionLog(String subject) async {
    if (_user == null) return;
    try {
      await _db.collection('users').doc(_user!.uid).collection('revision_history').add({
        'subject': subject,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding revision log: $e');
    }
  }

  Stream<QuerySnapshot> getRevisionHistoryStream() {
    if (_user == null) return Stream.empty();
    return _db.collection('users').doc(_user!.uid).collection('revision_history').snapshots();
  }
}
