import 'package:chetegram/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, User! 👋'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Today's Task"),
            Tab(text: "1st Reading"),
            Tab(text: "2nd Reading"),
            Tab(text: "3rd Reading"),
            Tab(text: "4th Reading"),
            Tab(text: "5th Reading"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Today's Task Tab
          ListView(
            children: const [
              SizedBox(height: 8),
              TaskCard(
                subject: 'History',
                topic: 'Ancient India',
                revision: '3rd Reading',
                nextRevision: 'in 14 days',
                isDone: false,
              ),
              TaskCard(
                subject: 'Geography',
                topic: 'Rivers of India',
                revision: '2nd Reading',
                nextRevision: 'in 3 days',
                isDone: true,
              ),
              TaskCard(
                subject: 'Polity',
                topic: 'Fundamental Rights',
                revision: '1st Reading',
                nextRevision: 'in 1 day',
                isDone: false,
              ),
            ],
          ),

          // Other Tabs - Placeholder
          const Center(child: Text('Content for 1st Reading')),
          const Center(child: Text('Content for 2nd Reading')),
          const Center(child: Text('Content for 3rd Reading')),
          const Center(child: Text('Content for 4th Reading')),
          const Center(child: Text('Content for 5th Reading')),
        ],
      ),
    );
  }
}
