import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package.dart';

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
    // 1. Validate the form
    if (_formKey.currentState!.validate()) {
      // 2. Create a new Task object from form data
      final newTask = Task(
        subject: _subjectController.text,
        topic: _topicController.text,
        revision: '1st Reading', // Default value for a new task
        nextRevisionDate: 'in 1 day', // Default value
        isDone: false,
      );

      // 3. Insert into the database
      await DatabaseHelper.instance.insertTask(newTask.toMap());

      // 4. Go back to the previous screen
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
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., History, Geography',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Ancient India, Rivers of India',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a topic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Save Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
