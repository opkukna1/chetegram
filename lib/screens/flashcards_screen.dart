import 'package:chetegram/services/firestore_service.dart';
import 'package:chetegram/widgets/flashcard_feed_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Feed'),
            Tab(text: 'Recommended'),
          ],
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            FlashcardFeedView(flashcardStream: _firestoreService.getFeedFlashcards()),
            FlashcardFeedView(flashcardStream: _firestoreService.getRecommendedFlashcards()),
          ],
        ),
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-flashcard'),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.deepPurple),
      ),
    );
  }
}
