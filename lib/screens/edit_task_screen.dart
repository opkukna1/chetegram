import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late TextEditingController _topicController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.task.subject);
    _topicController = TextEditingController(text: widget.task.topic);
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      // Task object ko naye data se update karein
      final updatedTask = Task(
        id: widget.task.id,
        subject: _subjectController.text,
        topic: _topicController.text,
        readingStage: widget.task.readingStage,
        nextRevisionDate: widget.task.nextRevisionDate,
        status: widget.task.status,
      );
      
      await DatabaseHelper.instance.updateTask(updatedTask.toMap());
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
      appBar: AppBar(title: const Text('Edit Topic')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Topic'),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a topic' : null,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _updateTask,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
