import 'package:chetegram/models/user_model.dart';
import 'package:chetegram/services/auth_service.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chetegram/screens/profile/user_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late TabController _tabController;
  
  // Future को null बना दें ताकि हम उसे दोबारा बना सकें
  Future<DocumentSnapshot?>? _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }
  
  void _loadProfile() {
    setState(() {
      _userProfileFuture = _getOrCreteUserProfile();
    });
  }
  
  // नया 'सेल्फ-हीलिंग' फंक्शन
  Future<DocumentSnapshot?> _getOrCreteUserProfile() async {
    // अगर हम किसी और की प्रोफाइल देख रहे हैं, तो बस उसे लाएं
    if (widget.userId != null) {
      return await _firestoreService.getUserProfile(widget.userId);
    }
    
    // अगर हम अपनी प्रोफाइल देख रहे हैं
    if (_currentUser == null) return null;

    DocumentSnapshot? profileDoc = await _firestoreService.getUserProfile(null);

    // अगर प्रोफाइल मौजूद नहीं है, तो उसे बनाएं
    if (profileDoc == null || !profileDoc.exists) {
      await _firestoreService.createUserProfile(
        uid: _currentUser!.uid,
        name: _currentUser!.displayName ?? "New User",
        email: _currentUser!.email!,
      );
      // बनाने के बाद, उसे दोबारा लाएं
      return await _firestoreService.getUserProfile(null);
    }
    
    // अगर प्रोफाइल पहले से है, तो उसे लौटा दें
    return profileDoc;
  }

  void _checkIfFollowing() async {
    // ... यह फंक्शन वैसा ही रहेगा
  }

  void _handleFollowButton() async {
    // ... यह फंक्शन वैसा ही रहेगा
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMyProfile = (widget.userId == null || widget.userId == _currentUser?.uid);
    String? profileUserId = widget.userId ?? _currentUser?.uid;

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
            // यह अब सिर्फ तभी दिखेगा जब कोई गंभीर एरर हो
            return const Center(child: Text('Profile not found or could not be created.'));
          }

          final user = UserModel.fromFirestore(snapshot.data!);

          // ... (बाकी का पूरा UI कोड (NestedScrollView) वैसा ही रहेगा जैसा पहले था)
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
                            : Container(), // Follow/Unfollow बटन के लिए जगह
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
                    Tab(text: 'Liked Flashcards'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // "My Flashcards" टैब का कंटेंट
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestoreService.getFlashcardsForUser(profileUserId!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('This user has no public flashcards.'));
                          }
                          final flashcards = snapshot.data!.docs.map((doc) => Flashcard.fromFirestore(doc)).toList();
                          
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8,
                            ),
                            itemCount: flashcards.length,
                            itemBuilder: (context, index) {
                              final card = flashcards[index];
                              return GestureDetector(
                                onTap: () => context.push('/flashcard-viewer', extra: {'flashcards': flashcards, 'index': index}),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (card.imageUrl.isNotEmpty)
                                        Expanded(child: Image.network(card.imageUrl, width: double.infinity, fit: BoxFit.cover))
                                      else
                                        Expanded(child: Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image_not_supported)))),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(card.frontText, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const Center(child: Text('Liked flashcards will appear here in the future.')),
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
