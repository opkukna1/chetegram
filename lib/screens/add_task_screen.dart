import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // State variables
  List<String> _subjects = [];
  List<String> _topics = [];
  String? _selectedSubject;
  String? _selectedTopic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final subjects = await _firestoreService.getSubjects();
    setState(() {
      _subjects = subjects;
      _isLoading = false;
    });
  }

  Future<void> _loadTopics(String subject) async {
    setState(() => _isLoading = true);
    final topics = await _firestoreService.getTopicsForSubject(subject);
    setState(() {
      _topics = topics;
      _isLoading = false;
    });
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        subject: _selectedSubject!,
        topic: _selectedTopic!,
        nextRevisionDate: Timestamp.now(),
        readingStage: 1,
        status: 'pending',
      );
      await _firestoreService.addTask(newTask);
      if (mounted) {
        context.pop();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Topic')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Subject Dropdown ---
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    hint: const Text('Choose Subject'),
                    items: _subjects.map((String subject) {
                      return DropdownMenuItem<String>(value: subject, child: Text(subject));
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedSubject = newValue;
                          _selectedTopic = null; // Topic reset karein
                          _topics = []; // Topic list khali karein
                        });
                        _loadTopics(newValue);
                      }
                    },
                    validator: (v) => v == null ? 'Please choose a subject' : null,
                  ),
                  const SizedBox(height: 24.0),

                  // --- Topic Dropdown ---
                  if (_selectedSubject != null)
                    DropdownButtonFormField<String>(
                      value: _selectedTopic,
                      hint: const Text('Choose Topic'),
                      items: _topics.map((String topic) {
                        return DropdownMenuItem<String>(value: topic, child: Text(topic));
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTopic = newValue;
                        });
                      },
                      validator: (v) => v == null ? 'Please choose a topic' : null,
                    ),
                  const SizedBox(height: 24.0),
                  
                  ElevatedButton(
                    onPressed: _submitTask,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0), textStyle: const TextStyle(fontSize: 18)),
                    child: const Text('Add Topic'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
