import 'package:chetegram/models/user_model.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum UserListType { followers, following }

class UserListScreen extends StatefulWidget {
  final String userId;
  final UserListType listType;

  const UserListScreen({super.key, required this.userId, required this.listType});
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    if (widget.listType == UserListType.followers) {
      _usersFuture = _firestoreService.getFollowers(widget.userId);
    } else {
      _usersFuture = _firestoreService.getFollowing(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.listType == UserListType.followers ? 'Followers' : 'Following')),
      body: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found in this list.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.name),
                subtitle: Text('@${user.email.split('@')[0]}'),
                onTap: () => context.push('/view-profile/${user.uid}'),
              );
            },
          );
        },
      ),
    );
  }
}
