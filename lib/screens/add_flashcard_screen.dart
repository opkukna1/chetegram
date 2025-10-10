import 'dart:io';
import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:chetegram/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
  final StorageService _storageService = StorageService();
  
  // State variables
  String? _selectedSubject;
  String? _selectedTopic;
  bool _isPublic = false;
  File? _imageFile;
  bool _isLoading = false;

  // --- Placeholder Data ---
  // Asli app mein yeh data aap Firebase se laayenge
  final Map<String, List<String>> _subjectsAndTopics = {
    'Geography': ['Motions of the Earth', 'Rivers of India', 'Mountains'],
    'History': ['Ancient India', 'Mughal Empire', 'Indus Valley Civilization'],
    'Polity': ['Fundamental Rights', 'Preamble', 'Parliament'],
  };
  // -------------------------
  
  late Color _selectedColor;
  final List<Color> _colors = [ /* ... */ ]; // Aapki color list yahaan

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors.isNotEmpty ? _colors.first : Colors.blue.shade100;
  }

  String _colorToHex(Color color) => '#${color.value.toRadixString(16).substring(2)}';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitFlashcard() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      String imageUrl = '';
      if (_imageFile != null) {
        // Image ko Firebase Storage par upload karein
        final downloadUrl = await _storageService.pickAndUploadImage(
          'flashcard_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}',
          _imageFile! // Pass the file to the service
        );
        if (downloadUrl != null) {
          imageUrl = downloadUrl;
        }
      }

      final newFlashcard = Flashcard(
        creatorId: user.uid,
        creatorName: user.displayName ?? 'Anonymous',
        creatorPicUrl: user.photoURL ?? '',
        subject: _selectedSubject!,
        topic: _selectedTopic!,
        frontText: _frontController.text,
        backText: _backController.text,
        colorHex: _colorToHex(_selectedColor),
        isPublic: _isPublic,
        imageUrl: imageUrl,
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
                  // --- Photo Add Section ---
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                      ),
                      child: _imageFile == null 
                        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo), Text("Add Photo")])) 
                        : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- Subject and Topic Dropdowns ---
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    hint: const Text('Choose Subject'),
                    items: _subjectsAndTopics.keys.map((String subject) {
                      return DropdownMenuItem<String>(value: subject, child: Text(subject));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSubject = newValue;
                        _selectedTopic = null; // Topic reset karein
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
                  
                  // --- Privacy Switch ---
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
}
