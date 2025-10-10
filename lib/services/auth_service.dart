import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // साइन अप करने का फंक्शन
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // लॉग इन करने का फंक्शन
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // लॉग आउट करने का फंक्शन
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth स्टेट में बदलाव को सुनने के लिए Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
