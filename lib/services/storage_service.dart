import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // यह फंक्शन एक File object और path लेता है और इमेज अपलोड करके उसका URL देता है
  Future<String?> uploadImage(String path, File file) async {
    try {
      TaskSnapshot snapshot = await _storage.ref().child(path).putFile(file);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }
}
