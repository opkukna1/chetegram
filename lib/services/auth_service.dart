import 'package:firebase_auth/firebase_auth.dart';
import 'package:chetegram/services/firestore_service.dart'; // FirestoreService इम्पोर्ट करें

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService(); // FirestoreService का इंस्टैंस बनाएं

  // साइन अप फंक्शन में 'name' पैरामीटर जोड़ें
  Future<User?> signUpWithEmailPassword(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Auth में यूज़र बनने के तुरंत बाद, Firestore में उसकी प्रोफाइल बनाएं
        await _firestoreService.createUserProfile(
          uid: user.uid,
          name: name,
          email: email,
        );
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // ... बाकी के signIn और signOut फंक्शन वैसे ही रहेंगे
  Future<User?> signInWithEmailPassword(String email, String password) async { ... }
  Future<void> signOut() async { ... }
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
