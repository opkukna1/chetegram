import 'package:chetegram/models/flashcard_model.dart';
import 'package:flutter/material.dart';

class FlashcardViewerScreen extends StatelessWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;

  const FlashcardViewerScreen({
    super.key,
    required this.flashcards,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final card = flashcards[index];
          // बैक टेक्स्ट को अलग-अलग पॉइंट्स में तोड़ें (सेमीकोलन ';' के आधार पर)
          final points = card.backText.split(';');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SingleChildScrollView( // लंबे कंटेंट के लिए स्क्रॉलिंग
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- मुख्य टाइटल (Front Text से) ---
                    Text(
                      card.frontText,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // --- पॉइंट्स की लिस्ट (Back Text से) ---
                    ...points.map((point) => _buildPointRow(point.trim(), context)).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // हर एक पॉइंट के लिए एक पंक्ति बनाने वाला विजेट
  Widget _buildPointRow(String point, BuildContext context) {
    if (point.isEmpty) return const SizedBox.shrink();

    // पॉइंट को ":" के आधार पर की (key) और वैल्यू (value) में तोड़ें
    final parts = point.split(':');
    final String key = parts[0];
    final String value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.purple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                children: [
                  TextSpan(
                    text: '$key: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
