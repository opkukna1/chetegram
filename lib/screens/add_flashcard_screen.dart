import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddFlashcardScreen extends StatefulWidget {
  const AddFlashcardScreen({super.key});

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  String? _selectedSubject;
  String? _selectedTopic;
  bool _isPublic = false;
  bool _isLoading = false;

  final Map<String, List<String>> _subjectsAndTopics = {
    'Geography': ['Motions of the Earth', 'Rivers of India', 'Mountains'],
    'History': ['Ancient India', 'Mughal Empire', 'Indus Valley Civilization'],
    'Polity': ['Fundamental Rights', 'Preamble', 'Parliament'],
  };
  
  late Color _selectedColor;
  final List<Color> _colors = [
    Colors.blue.shade100, Colors.green.shade100, Colors.orange.shade100,
    Colors.red.shade100, Colors.purple.shade100, Colors.yellow.shade100
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors.first;
  }

  String _colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2)}';

  Future<void> _submitFlashcard() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newFlashcard = Flashcard(
        creatorId: user.uid,
        creatorName: user.displayName ?? 'Anonymous',
        subject: _selectedSubject!,
        topic: _selectedTopic!,
        frontText: _frontController.text,
        backText: _backController.text,
        colorHex: _colorToHex(_selectedColor),
        isPublic: _isPublic,
        createdAt: Timestamp.now(),
      );

      await _firestoreService.addFlashcard(newFlashcard);
      setState(() => _isLoading = false);

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Flashcard'),
        actions: [
          if (_isLoading) 
            const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else 
            IconButton(icon: const Icon(Icons.save), onPressed: _submitFlashcard),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    hint: const Text('Choose Subject'),
                    items: _subjectsAndTopics.keys.map((String subject) {
                      return DropdownMenuItem<String>(value: subject, child: Text(subject));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                        _selectedTopic = null;
                      });
                    },
                    validator: (v) => v == null ? 'Subject is required' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedSubject != null)
                    DropdownButtonFormField<String>(
                      value: _selectedTopic,
                      hint: const Text('Choose Topic'),
                      items: _subjectsAndTopics[_selectedSubject]!.map((String topic) {
                        return DropdownMenuItem<String>(value: topic, child: Text(topic));
                      }).toList(),
                      onChanged: (newValue) => setState(() => _selectedTopic = newValue),
                      validator: (v) => v == null ? 'Topic is required' : null,
                    ),

                  const SizedBox(height: 16),
                  TextFormField(controller: _frontController, decoration: const InputDecoration(labelText: 'Front Text / Title'), maxLength: 200, validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _backController, decoration: const InputDecoration(labelText: 'Back Text / Details'), maxLines: 5, maxLength: 200, validator: (v) => v!.isEmpty ? 'Required' : null),
                  
                  SwitchListTile(
                    title: const Text('Make this flashcard public?'),
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitFlashcard,
                    child: const Text('Save Flashcard'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
