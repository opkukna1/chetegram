import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/firestore_service.dart'; // FirestoreService का उपयोग करें
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
  final FirestoreService _firestoreService = FirestoreService(); // FirestoreService का इंस्टैंस बनाएं

  @override
  void initState() {
    super.initState();
    // Subject और Topic को बदला नहीं जा सकता, इसलिए उन्हें सिर्फ दिखाएंगे
    _subjectController = TextEditingController(text: widget.task.subject);
    _topicController = TextEditingController(text: widget.task.topic);
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      // Task ऑब्जेक्ट को नए डेटा से अपडेट करें
      final updatedTask = Task(
        id: widget.task.id, // ID वही रहेगा
        subject: _subjectController.text,
        topic: _topicController.text,
        readingStage: widget.task.readingStage,
        nextRevisionDate: widget.task.nextRevisionDate,
        status: widget.task.status,
      );
      
      // DatabaseHelper की जगह FirestoreService का उपयोग करें
      await _firestoreService.updateTask(updatedTask);
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
              // Subject और Topic को सिर्फ पढ़ने के लिए रखें (disabled)
              TextFormField(
                controller: _subjectController,
                enabled: false, // एडिट नहीं किया जा सकता
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Topic'),
                // Topic को एडिट करने की अनुमति दे सकते हैं
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
