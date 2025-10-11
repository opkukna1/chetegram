import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:chetegram/widgets/task_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirestoreService _firestoreService = FirestoreService();
  final List<int> revisionIntervals = [1, 2, 4, 7, 16, 30];

  String? _selectedSubjectFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }
  
  Future<void> _markTaskAsDone(Task task) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (!task.nextRevisionDate.toDate().isBefore(today.add(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can only mark this task on its scheduled day.")));
      return;
    }

    await _firestoreService.addRevisionLog(task.subject);

    if (task.readingStage < 6) {
      task.readingStage += 1;
      int daysToAdd = revisionIntervals[task.readingStage - 2]; 
      task.nextRevisionDate = Timestamp.fromDate(DateTime.now().add(Duration(days: daysToAdd)));
    } else {
      task.status = 'completed';
    }
    await _firestoreService.updateTask(task);
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
                Navigator.pop(context);
                context.push('/edit-task', extra: task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                if (task.id != null) {
                  await _firestoreService.deleteTask(task.id!);
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  void _showFilterDialog() async {
    final subjects = await _firestoreService.getSubjects();
    subjects.insert(0, 'All');

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return ListTile(
              title: Text(subject),
              leading: Icon(
                _selectedSubjectFilter == subject || (_selectedSubjectFilter == null && subject == 'All')
                  ? Icons.check_circle
                  : Icons.circle_outline,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () {
                setState(() {
                  _selectedSubjectFilter = (subject == 'All') ? null : subject;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
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
        title: Text(_selectedSubjectFilter ?? 'All Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
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
            Tab(text: "6th Reading"),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getTasksStream(subject: _selectedSubjectFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tasks found. Tap "+" to add one!', textAlign: TextAlign.center));
          }

          final allTasks = snapshot.data!.docs.map((doc) => Task.fromFirestore(doc)).toList();
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          final todaysTasks = allTasks.where((task) =>
              task.nextRevisionDate.toDate().isBefore(today.add(const Duration(days: 1))) &&
              task.status == 'pending').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(todaysTasks),
              _buildTaskList(allTasks.where((t) => t.readingStage == 1).toList()),
              _buildTaskList(allTasks.where((t) => t.readingStage == 2).toList()),
              _buildTaskList(allTasks.where((t) => t.readingStage == 3).toList()),
              _buildTaskList(allTasks.where((t) => t.readingStage == 4).toList()),
              _buildTaskList(allTasks.where((t) => t.readingStage == 5).toList()),
              _buildTaskList(allTasks.where((t) => t.readingStage == 6).toList()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-task'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) return const Center(child: Text('No topics here.'));
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return GestureDetector(
          onLongPress: () => _showEditDeleteMenu(context, task),
          child: TaskCard(
            subject: task.subject,
            topic: task.topic,
            revisionText: '${task.readingStage} Reading',
            nextRevision: DateFormat.yMMMd().format(task.nextRevisionDate.toDate()),
            onMarkAsDone: (isDone) => _markTaskAsDone(task),
          ),
        );
      },
    );
  }
}
