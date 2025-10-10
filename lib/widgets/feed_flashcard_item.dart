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
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Flashcard Content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildNoteCard(widget.flashcard, context),
          ),
        ),
        
        // UI Overlay (User Info and Action Buttons)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- User Info Header ---
              GestureDetector(
                onTap: () => context.push('/profile/${widget.flashcard.creatorId}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: widget.flashcard.creatorPicUrl.isNotEmpty
                          ? NetworkImage(widget.flashcard.creatorPicUrl)
                          : null,
                      child: widget.flashcard.creatorPicUrl.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.flashcard.creatorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, shadows: [Shadow(blurRadius: 2)]),
                    ),
                  ],
                ),
              ),

              // --- Action Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      // Like Button
                      StreamBuilder<bool>(
                        stream: _firestoreService.checkIfLiked(widget.flashcard.id!),
                        builder: (context, snapshot) {
                          _isLiked = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              _firestoreService.toggleLike(widget.flashcard.id!, _isLiked);
                            },
                          );
                        },
                      ),
                      Text(widget.flashcard.likeCount.toString(), style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(Icons.comment, color: Colors.white, size: 30),
                        onPressed: () { /* Comment logic future mein */ },
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white, size: 30),
                        onPressed: () { /* Share logic future mein */ },
                      ),
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

  // Note Card UI (flashcard_viewer_screen se liya gaya)
  Widget _buildNoteCard(Flashcard card, BuildContext context) {
    final points = card.backText.split(';');
    return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (card.imageUrl.isNotEmpty) Image.network(card.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              Padding(
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
            ],
          ),
        ),
      );
  }
  
  Widget _buildPointRow(String point, BuildContext context) {
    // ... yeh function waisa hi hai jaisa flashcard_viewer_screen mein tha
    if (point.isEmpty) return const SizedBox.shrink();
    final parts = point.split(':');
    final String key = parts[0];
    final String value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
    return Padding( /* ... */ );
  }
}
