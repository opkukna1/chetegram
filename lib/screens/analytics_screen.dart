import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _totalTopics = 0;
  List<Task> _stage2Tasks = [];
  List<Task> _stage3Tasks = [];
  List<Task> _stage4Tasks = [];
  List<Task> _stage5Tasks = [];
  List<Task> _completedTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    final dbHelper = DatabaseHelper.instance;
    _totalTopics = await dbHelper.getTasksCount();
    _stage2Tasks = (await dbHelper.getTasksByStage(2)).map((map) => Task.fromMap(map)).toList();
    _stage3Tasks = (await dbHelper.getTasksByStage(3)).map((map) => Task.fromMap(map)).toList();
    _stage4Tasks = (await dbHelper.getTasksByStage(4)).map((map) => Task.fromMap(map)).toList();
    _stage5Tasks = (await dbHelper.getTasksByStage(5)).map((map) => Task.fromMap(map)).toList();
    _completedTasks = (await dbHelper.getCompletedTasks()).map((map) => Task.fromMap(map)).toList();
    setState(() {}); // UI को अपडेट करने के लिए
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
        title: const Text('My Progress 📊'),
      ),
      body: Column(
        children: [
          // --- Stats Cards ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('$_totalTopics', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          const Text('Total Topics'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('${_completedTasks.length}', style: Theme.of(context).textTheme.headlineMedium),
                           const SizedBox(height: 4),
                          const Text('Mastered'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Tabs for each stage ---
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: '2nd Reading Done'),
              Tab(text: '3rd Reading Done'),
              Tab(text: '4th Reading Done'),
              Tab(text: '5th Reading Done'),
              Tab(text: 'Mastered'),
            ],
          ),

          // --- Tab Content ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStageList(_stage2Tasks),
                _buildStageList(_stage3Tasks),
                _buildStageList(_stage4Tasks),
                _buildStageList(_stage5Tasks),
                _buildStageList(_completedTasks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No topics have reached this stage yet.'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.topic),
          subtitle: Text(task.subject),
        );
      },
    );
  }
}
