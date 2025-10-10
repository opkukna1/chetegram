import 'package:chetegram/models/user_model.dart';
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

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  late Future<DocumentSnapshot?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 टैब्स के लिए
    _loadProfile();
  }
  
  void _loadProfile() {
    setState(() {
      _userProfileFuture = _firestoreService.getUserProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return const Center(child: Text('Could not load profile.'));
          }

          final user = UserModel.fromFirestore(snapshot.data!);

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await _authService.signOut();
                        if (mounted) context.go('/login');
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // कवर फोटो
                        user.coverPhotoUrl.isNotEmpty
                            ? Image.network(user.coverPhotoUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey.shade300),
                        // प्रोफाइल पिक्चर
                        Positioned(
                          bottom: -1, // थोड़ा ओवरलैप करने के लिए
                          left: 16,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: user.profilePicUrl.isNotEmpty ? NetworkImage(user.profilePicUrl) : null,
                              child: user.profilePicUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => context.push('/edit-profile').then((_) => _loadProfile()),
                          child: const Text('Edit Profile'),
                        ),
                      ),
                      Text(user.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('@${user.email.split('@')[0]}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(user.bio.isNotEmpty ? user.bio : 'No bio available.'),
                      const SizedBox(height: 8),
                      if(user.location.isNotEmpty) Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(user.location, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(text: '${user.followingCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' Following'),
                            ]),
                          ),
                          const SizedBox(width: 16),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(text: '${user.followersCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' Followers'),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'My Flashcards'),
                    Tab(text: 'Shared Flashcards'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      // भविष्य में यहाँ यूज़र के फ्लैशकार्ड्स की लिस्ट आएगी
                      Center(child: Text('Your created flashcards will appear here.')),
                      Center(child: Text('Flashcards shared by you will appear here.')),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
