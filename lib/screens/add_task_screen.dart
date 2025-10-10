import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        subject: _subjectController.text,
        topic: _topicController.text,
        revision: '1st Reading',
        nextRevisionDate: 'in 1 day',
        isDone: false,
      );
      await DatabaseHelper.instance.insertTask(newTask.toMap());
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder(), hintText: 'e.g., History, Geography'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Topic', border: OutlineInputBorder(), hintText: 'e.g., Ancient India, Rivers of India'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a topic' : null,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0), textStyle: const TextStyle(fontSize: 18)),
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
