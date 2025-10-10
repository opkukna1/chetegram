import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late Future<List<Flashcard>> _flashcardsFuture;

  @override
  void initState() {
    super.initState();
    _refreshFlashcards();
  }

  void _refreshFlashcards() {
    setState(() {
      _flashcardsFuture = DatabaseHelper.instance.getAllFlashcards().then(
            (maps) => maps.map((map) => Flashcard.fromMap(map)).toList(),
      );
    });
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards ✨'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: FutureBuilder<List<Flashcard>>(
        future: _flashcardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No flashcards yet. Create one!'));
          }
          final flashcards = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final card = flashcards[index];
              return Card(
                color: _hexToColor(card.colorHex),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(card.topic, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const Spacer(),
                      Center(child: Text(card.frontText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16))),
                      const Spacer(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // यहाँ context.go को context.push से बदल दिया गया है
          context.push('/add-flashcard').then((_) => _refreshFlashcards());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
