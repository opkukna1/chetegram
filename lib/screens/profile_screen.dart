import 'dart:io';
import 'package:chetegram/services/firestore_service.dart';
import 'package:chetegram/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _firestoreService.getUserProfile(null).then((doc) {
      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _locationController.text = data['location'] ?? '';
        setState(() {
          _profilePicUrl = data['profilePicUrl'] ?? '';
          _coverPhotoUrl = data['coverPhotoUrl'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
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
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading) 
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else 
            IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (imageFile == null) return;
                      setState(() => _isLoading = true);
                      final url = await _storageService.uploadImage('cover_photos/${_currentUser!.uid}', File(imageFile.path));
                      if (url != null) setState(() => _coverPhotoUrl = url);
                      setState(() => _isLoading = false);
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        image: _coverPhotoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(_coverPhotoUrl), fit: BoxFit.cover) : null,
                      ),
                      child: _coverPhotoUrl.isEmpty ? const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)) : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (imageFile == null) return;
                        setState(() => _isLoading = true);
                        final url = await _storageService.uploadImage('profile_pics/${_currentUser!.uid}', File(imageFile.path));
                        if (url != null) setState(() => _profilePicUrl = url);
                        setState(() => _isLoading = false);
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.grey.shade400,
                          backgroundImage: _profilePicUrl.isNotEmpty ? NetworkImage(_profilePicUrl) : null,
                          child: _profilePicUrl.isEmpty ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white) : null,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder())),
            ],
          ),
    );
  }
}
