import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:chetegram/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // तारीख फॉर्मेट करने के लिए

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _todaysTasks = [];
  List<Task> _stage1Tasks = [];
  List<Task> _stage2Tasks = [];
  List<Task> _stage3Tasks = [];
  List<Task> _stage4Tasks = [];
  List<Task> _stage5Tasks = [];

  // रिवीजन के दिनों का क्रम: 1 दिन, 3 दिन, 7 दिन, 14 दिन, 30 दिन
  final List<int> revisionIntervals = [1, 3, 7, 14, 30];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _refreshAllTasks();
  }

  Future<void> _refreshAllTasks() async {
    final allTasks = (await DatabaseHelper.instance.getAllTasks())
        .map((map) => Task.fromMap(map))
        .toList();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    setState(() {
      _todaysTasks = allTasks.where((task) =>
          task.nextRevisionDate.isBefore(today.add(const Duration(days: 1))) &&
          task.status == 'pending').toList();

      _stage1Tasks = allTasks.where((t) => t.readingStage == 1).toList();
      _stage2Tasks = allTasks.where((t) => t.readingStage == 2).toList();
      _stage3Tasks = allTasks.where((t) => t.readingStage == 3).toList();
      _stage4Tasks = allTasks.where((t) => t.readingStage == 4).toList();
      _stage5Tasks = allTasks.where((t) => t.readingStage == 5).toList();
    });
  }

  Future<void> _markTaskAsDone(Task task) async {
    int currentStage = task.readingStage;
    
    if (currentStage < 5) {
      task.readingStage += 1; // अगले स्टेज पर जाएं
      // अगले रिविजन की तारीख सेट करें
      int daysToAdd = revisionIntervals[currentStage -1];
      task.nextRevisionDate = DateTime.now().add(Duration(days: daysToAdd));
    } else {
      // 5वीं रीडिंग के बाद, स्टेटस 'completed' कर दें
      task.status = 'completed';
    }

    await DatabaseHelper.instance.updateTask(task.toMap());
    _refreshAllTasks(); // UI रिफ्रेश करें
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // लिस्ट बनाने के लिए एक हेल्पर विजेट
  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No topics in this stage.'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          subject: task.subject,
          topic: task.topic,
          revisionText: '${task.readingStage} Reading',
          nextRevision: DateFormat.yMMMd().format(task.nextRevisionDate),
          onMarkAsDone: (isDone) {
            _markTaskAsDone(task);
          },
        );
      },
    );
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_todaysTasks),
          _buildTaskList(_stage1Tasks),
          _buildTaskList(_stage2Tasks),
          _buildTaskList(_stage3Tasks),
          _buildTaskList(_stage4Tasks),
          _buildTaskList(_stage5Tasks),
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
