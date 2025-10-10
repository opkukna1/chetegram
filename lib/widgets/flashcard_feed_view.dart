import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/widgets/feed_flashcard_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FlashcardFeedView extends StatelessWidget {
  final Stream<QuerySnapshot> flashcardStream;
  const FlashcardFeedView({super.key, required this.flashcardStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: flashcardStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No flashcards in this feed.'));
        }

        final flashcards = snapshot.data!.docs.map((doc) => Flashcard.fromFirestore(doc)).toList();

        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            return FeedFlashcardItem(flashcard: flashcards[index]);
          },
        );
      },
    );
  }
}
