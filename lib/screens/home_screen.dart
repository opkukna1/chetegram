import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/database_helper.dart';
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
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = _getTasksFromDb();
    });
  }

  Future<List<Task>> _getTasksFromDb() async {
    final dbHelper = DatabaseHelper.instance;
    final taskMaps = await dbHelper.getAllTasks();
    return taskMaps.map((map) => Task.fromMap(map)).toList();
  }

  Future<void> _addTask() async {
    // This is a dummy task for demonstration
    final newTask = Task(
      subject: 'New Subject',
      topic: 'A New Topic to Learn',
      revision: '1st Reading',
      nextRevisionDate: 'in 1 day',
      isDone: false,
    );
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertTask(newTask.toMap());
    _refreshTasks(); // Refresh the list after adding
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
          FutureBuilder<List<Task>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tasks found. Add one!'));
              }

              final tasks = snapshot.data!;
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    subject: task.subject,
                    topic: task.topic,
                    revision: task.revision,
                    nextRevision: task.nextRevisionDate,
                    isDone: task.isDone,
                  );
                },
              );
            },
          ),
          // Other Tabs - Placeholder
          const Center(child: Text('Content for 1st Reading')),
          const Center(child: Text('Content for 2nd Reading')),
          const Center(child: Text('Content for 3rd Reading')),
          const Center(child: Text('Content for 4th Reading')),
          const Center(child: Text('Content for 5th Reading')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(LucideIcons.plus),
      ),
    );
  }
}
