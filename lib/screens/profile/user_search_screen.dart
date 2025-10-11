import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:chetegram/models/user_model.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await _firestoreService.searchUsers(query);
    setState(() {
      _searchResults = results.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for users...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: _searchResults.isEmpty
          ? const Center(child: Text('Type a name to search.'))
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profilePicUrl.isNotEmpty ? NetworkImage(user.profilePicUrl) : null,
                    child: user.profilePicUrl.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () {
                    // दूसरे यूज़र की प्रोफाइल के लिए नए रूट का उपयोग करें
                    // .push() का उपयोग करने से बैक बटन सही से काम करेगा
                    context.push('/view-profile/${user.uid}');
                  },
                );
              },
            ),
    );
  }
}
