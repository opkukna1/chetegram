import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddFlashcardScreen extends StatefulWidget {
  const AddFlashcardScreen({super.key});

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  // Color selection
  final List<Color> _colors = [
    Colors.blue.shade100, Colors.green.shade100, Colors.orange.shade100,
    Colors.red.shade100, Colors.purple.shade100, Colors.yellow.shade100
  ];
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors.first;
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  Future<void> _submitFlashcard() async {
    if (_formKey.currentState!.validate()) {
      final newFlashcard = Flashcard(
        subject: _subjectController.text,
        topic: _topicController.text,
        frontText: _frontController.text,
        backText: _backController.text,
        colorHex: _colorToHex(_selectedColor),
      );

      await DatabaseHelper.instance.insertFlashcard(newFlashcard.toMap());

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Flashcard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Subject'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _topicController, decoration: const InputDecoration(labelText: 'Topic'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _frontController, decoration: const InputDecoration(labelText: 'Front Side (Question/Keyword)'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _backController, decoration: const InputDecoration(labelText: 'Back Side (Answer/Detail)'), maxLines: 5, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 24),
              const Text('Choose a color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12.0,
                children: _colors.map((color) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.blueAccent : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                )).toList(),
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
