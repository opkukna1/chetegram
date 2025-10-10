import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String subject;
  final String topic;
  final String revisionText; // 'revision' का नाम बदलकर 'revisionText' कर दिया
  final String nextRevision;
  final bool isDone;
  final Function(bool?)? onMarkAsDone; // क्लिक को हैंडल करने के लिए नया फंक्शन

  const TaskCard({
    super.key,
    required this.subject,
    required this.topic,
    required this.revisionText,
    required this.nextRevision,
    this.isDone = false,
    this.onMarkAsDone, // कंस्ट्रक्टर में जोड़ा गया
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          subject,
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(
                        revisionText, // 'revision' की जगह 'revisionText'
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    topic,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Next: $nextRevision',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: isDone,
                onChanged: onMarkAsDone, // चेकबॉक्स में फंक्शन जोड़ा गया
                shape: const CircleBorder(),
                activeColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
