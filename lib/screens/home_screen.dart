import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:chetegram/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _todaysTasks = [];
  List<Task> _allTasks = []; // Ab hum saare tasks ko ek hi list mein rakhenge

  // Naya Revision Schedule (dinon ka antar)
  // Stage 1 ke baad -> +1 din
  // Stage 2 ke baad -> +2 din (total 3)
  // Stage 3 ke baad -> +4 din (total 7)
  // Stage 4 ke baad -> +7 din (total 14)
  // Stage 5 ke baad -> +16 din (total 30)
  final List<int> revisionIntervals = [1, 2, 4, 7, 16];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this); // 6 stages + Today's Task
    _refreshAllTasks();
  }

  Future<void> _refreshAllTasks() async {
    final allTasksFromDb = (await DatabaseHelper.instance.getAllTasks())
        .map((map) => Task.fromMap(map))
        .toList();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    setState(() {
      _allTasks = allTasksFromDb;
      _todaysTasks = _allTasks.where((task) =>
          task.nextRevisionDate.isBefore(today.add(const Duration(days: 1))) &&
          task.status == 'pending').toList();
    });
  }

  Future<void> _markTaskAsDone(Task task) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // Check karein ki marking aaj hi possible hai ya nahi
    if (!task.nextRevisionDate.isBefore(today.add(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only mark this task on its scheduled day."))
      );
      return;
    }

    int currentStage = task.readingStage;
    
    if (currentStage < 6) { // Ab 6 stages hain
      task.readingStage += 1;
      int daysToAdd = revisionIntervals[currentStage - 1];
      task.nextRevisionDate = DateTime.now().add(Duration(days: daysToAdd));
    } else {
      task.status = 'completed'; // 6th reading ke baad
    }

    await DatabaseHelper.instance.updateTask(task.toMap());
    _refreshAllTasks();
  }
  
  void _showEditDeleteMenu(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context); // Bottom sheet ko band karo
                // Edit screen par jao
                context.push('/edit-task', extra: task).then((_) => _refreshAllTasks());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context); // Bottom sheet ko band karo
                await DatabaseHelper.instance.deleteTask(task.id!);
                _refreshAllTasks();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No topics here.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // FAB ke liye space
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return GestureDetector(
          onLongPress: () => _showEditDeleteMenu(context, task),
          child: TaskCard(
            subject: task.subject,
            topic: task.topic,
            revisionText: '${task.readingStage} Reading',
            nextRevision: DateFormat.yMMMd().format(task.nextRevisionDate),
            onMarkAsDone: (isDone) => _markTaskAsDone(task),
          ),
        );
      },
    );
  }

  // Stage ke hisaab se tasks filter karne ke liye
  List<Task> _getTasksForStage(int stage) {
    return _allTasks.where((t) => t.readingStage == stage).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, User! 👋'),
        actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})],
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
            Tab(text: "6th Reading"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_todaysTasks),
          _buildTaskList(_getTasksForStage(1)),
          _buildTaskList(_getTasksForStage(2)),
          _buildTaskList(_getTasksForStage(3)),
          _buildTaskList(_getTasksForStage(4)),
          _buildTaskList(_getTasksForStage(5)),
          _buildTaskList(_getTasksForStage(6)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-task').then((_) => _refreshAllTasks());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
