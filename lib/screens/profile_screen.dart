import 'package:chetegram/models/user_model.dart';
import 'package:chetegram/services/auth_service.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chetegram/screens/profile/user_list_screen.dart'; // UserListType के लिए इम्पोर्ट करें

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  late Future<DocumentSnapshot?> _userProfileFuture;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  bool _isFollowing = false;
  bool _isLoadingFollow = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
    _checkIfFollowing();
  }
  
  void _loadProfile() {
    setState(() {
      _userProfileFuture = _firestoreService.getUserProfile(widget.userId);
    });
  }

  void _checkIfFollowing() async {
    if (widget.userId == null || widget.userId == _currentUserId) {
      setState(() => _isLoadingFollow = false);
      return;
    }
    bool following = await _firestoreService.isFollowing(widget.userId!);
    if (mounted) {
      setState(() {
        _isFollowing = following;
        _isLoadingFollow = false;
      });
    }
  }

  void _handleFollowButton() async {
    if (_currentUserId == null || widget.userId == null) return;

    setState(() => _isLoadingFollow = true);

    if (_isFollowing) {
      await _firestoreService.unfollowUser(widget.userId!);
    } else {
      await _firestoreService.followUser(widget.userId!);
    }
    
    _checkIfFollowing();
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMyProfile = (widget.userId == null || widget.userId == _currentUserId);

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found.'));
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
                    if(isMyProfile)
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
                        user.coverPhotoUrl.isNotEmpty
                            ? Image.network(user.coverPhotoUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey.shade300),
                        Positioned(
                          bottom: -1,
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
                        child: isMyProfile
                            ? OutlinedButton(
                                onPressed: () => context.push('/edit-profile').then((_) => _loadProfile()),
                                child: const Text('Edit Profile'),
                              )
                            : _isLoadingFollow 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : _isFollowing
                                    ? OutlinedButton(onPressed: _handleFollowButton, child: const Text('Unfollowing'))
                                    : ElevatedButton(onPressed: _handleFollowButton, child: const Text('Follow')),
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
                          GestureDetector(
                            onTap: () => context.push('/user-list', extra: {'userId': user.uid, 'listType': UserListType.following}),
                            child: Text.rich(TextSpan(children: [
                              TextSpan(text: '${user.followingCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' Following'),
                            ])),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => context.push('/user-list', extra: {'userId': user.uid, 'listType': UserListType.followers}),
                            child: Text.rich(TextSpan(children: [
                              TextSpan(text: '${user.followersCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const TextSpan(text: ' Followers'),
                            ])),
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
                      Center(child: Text('User\'s created flashcards will appear here.')),
                      Center(child: Text('Flashcards shared by this user will appear here.')),
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
