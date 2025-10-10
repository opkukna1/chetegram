import 'package:chetegram/services/firestore_service.dart';
import 'package:chetegram/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();
  final _currentUser = FirebaseAuth.instance.currentUser;

  String _profilePicUrl = '';
  String _coverPhotoUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // मौजूदा डेटा लोड करें
    _firestoreService.getUserProfile().then((doc) {
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _locationController.text = data['location'] ?? '';
        setState(() {
          _profilePicUrl = data['profilePicUrl'] ?? '';
          _coverPhotoUrl = data['coverPhotoUrl'] ?? '';
        });
      }
    });
  }

  void _saveProfile() async {
    if (_currentUser == null) return;
    setState(() => _isLoading = true);

    await _firestoreService.updateUserProfile(_currentUser!.uid, {
      'name': _nameController.text,
      'bio': _bioController.text,
      'location': _locationController.text,
      'profilePicUrl': _profilePicUrl,
      'coverPhotoUrl': _coverPhotoUrl,
    });

    setState(() => _isLoading = false);
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading) const CircularProgressIndicator() else IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // इमेज अपलोड सेक्शन
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // कवर फोटो
              GestureDetector(
                onTap: () async {
                  final url = await _storageService.pickAndUploadImage('cover_photos/${_currentUser!.uid}');
                  if (url != null) setState(() => _coverPhotoUrl = url);
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: _coverPhotoUrl.isNotEmpty ? Image.network(_coverPhotoUrl, fit: BoxFit.cover) : const Icon(Icons.add_a_photo),
                ),
              ),
              // प्रोफाइल फोटो
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: GestureDetector(
                  onTap: () async {
                    final url = await _storageService.pickAndUploadImage('profile_pics/${_currentUser!.uid}');
                    if (url != null) setState(() => _profilePicUrl = url);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade400,
                    backgroundImage: _profilePicUrl.isNotEmpty ? NetworkImage(_profilePicUrl) : null,
                    child: _profilePicUrl.isEmpty ? const Icon(Icons.add_a_photo, size: 40) : null,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 16),
          TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio')),
          const SizedBox(height: 16),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
        ],
      ),
    );
  }
}
