import 'package:chetegram/models/flashcard_model.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeedFlashcardItem extends StatefulWidget {
  final Flashcard flashcard;
  const FeedFlashcardItem({super.key, required this.flashcard});
  @override
  State<FeedFlashcardItem> createState() => _FeedFlashcardItemState();
}

class _FeedFlashcardItemState extends State<FeedFlashcardItem> {
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildNoteCard(widget.flashcard, context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.push('/view-profile/${widget.flashcard.creatorId}'),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Text(widget.flashcard.creatorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, shadows: [Shadow(blurRadius: 2)])),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      StreamBuilder<bool>(
                        stream: _firestoreService.checkIfLiked(widget.flashcard.id!),
                        builder: (context, snapshot) {
                          bool isLiked = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white, size: 30),
                            onPressed: () => _firestoreService.toggleLike(widget.flashcard.id!, isLiked),
                          );
                        },
                      ),
                      Text(widget.flashcard.likeCount.toString(), style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),
                      IconButton(icon: const Icon(Icons.comment, color: Colors.white, size: 30), onPressed: () {}),
                      const SizedBox(height: 20),
                      IconButton(icon: const Icon(Icons.share, color: Colors.white, size: 30), onPressed: () {}),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteCard(Flashcard card, BuildContext context) {
    final points = card.backText.split(';');
    return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.frontText, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ...points.map((point) => _buildPointRow(point.trim(), context)).toList(),
              ],
            ),
          ),
        ),
      );
  }
  
  Widget _buildPointRow(String point, BuildContext context) {
    if (point.isEmpty) return const SizedBox.shrink();
    final parts = point.split(':');
    final String key = parts[0];
    final String value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.purple.shade300, size: 20),
          const SizedBox(width: 12),
          Expanded(child: RichText(text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, color: Colors.black87),
            children: [
              TextSpan(text: '$key: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: value),
            ],
          ))),
        ],
      ),
    );
  }
}
