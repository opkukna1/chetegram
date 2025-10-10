import 'package:chetegram/services/auth_service.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  late Future<DocumentSnapshot?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  void _loadProfile() {
    setState(() {
      _userProfileFuture = _firestoreService.getUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return const Center(child: Text('Could not load profile.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String name = userData['name'] ?? 'No Name';
          final String email = userData['email'] ?? 'No Email';
          final int followers = userData['followersCount'] ?? 0;
          final int following = userData['followingCount'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => context.push('/edit-profile').then((_) => _loadProfile()),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Center(child: Text(email, style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Followers', followers.toString()),
                  _buildStatColumn('Following', following.toString()),
                ],
              ),
              const Divider(height: 48),
              Text('My Flashcards', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              const Center(child: Text('You have not created any public flashcards yet.'))
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
