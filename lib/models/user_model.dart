import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final String location;
  final String profilePicUrl;
  final String coverPhotoUrl;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.bio = '',
    this.location = '',
    this.profilePicUrl = '',
    this.coverPhotoUrl = '',
    this.followersCount = 0,
    this.followingCount = 0,
  });

  // Firestore से डेटा को UserModel में बदलना
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      profilePicUrl: data['profilePicUrl'] ?? '',
      coverPhotoUrl: data['coverPhotoUrl'] ?? '',
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
    );
  }

  // UserModel को Firestore में भेजने के लिए Map में बदलना
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'location': location,
      'profilePicUrl': profilePicUrl,
      'coverPhotoUrl': coverPhotoUrl,
    };
  }
}
