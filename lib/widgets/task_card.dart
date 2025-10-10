import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String subject;
  final String topic;
  final String revision;
  final String nextRevision;
  final bool isDone;

  const TaskCard({
    super.key,
    required this.subject,
    required this.topic,
    required this.revision,
    required this.nextRevision,
    this.isDone = false,
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
                  // Subject and Revision Row
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
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        revision,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Topic Text
                  Text(
                    topic,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Next Revision Text
                  Text(
                    'Next Revision: $nextRevision',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Checkbox
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: isDone,
                onChanged: (bool? value) {
                  // TODO: Add functionality to update task status
                },
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
