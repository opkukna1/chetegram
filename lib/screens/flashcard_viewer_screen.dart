import 'package:chetegram/models/flashcard_model.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class FlashcardViewerScreen extends StatelessWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;

  const FlashcardViewerScreen({
    super.key,
    required this.flashcards,
    required this.initialIndex,
  });

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    // PageController का उपयोग करके हम यह तय करते हैं कि कौन सा कार्ड पहले दिखेगा
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(flashcards[initialIndex].subject),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final card = flashcards[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FlipCard(
              front: _buildCardSide(card.frontText, card.colorHex, context, isFront: true),
              back: _buildCardSide(card.backText, card.colorHex, context, isFront: false),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide(String text, String colorHex, BuildContext context, {required bool isFront}) {
    return Card(
      color: _hexToColor(colorHex),
      elevation: 8,
      child: Center(
        child: SingleChildScrollView( // लंबे टेक्स्ट के लिए स्क्रॉलिंग
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (isFront) ...[
                const SizedBox(height: 20),
                const Text("Tap to see answer", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
