import 'package:chetegram/models/task_model.dart';
import 'package:chetegram/models/timetable_model.dart';
import 'package:chetegram/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final Set<String> _completedSlots = {}; // आज पूरे किए गए स्लॉट्स को ट्रैक करने के लिए

  void _deleteTimeTable(String id) async {
    await _firestoreService.deleteTimeTable(id);
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time Table Deleted')));
    }
  }

  void _markSlotAsDone(String subject, String topic) async {
    bool exists = await _firestoreService.doesTaskExist(subject, topic);

    if (!exists) {
      final newTask = Task(
        subject: subject,
        topic: topic,
        nextRevisionDate: Timestamp.now(),
        readingStage: 1,
        status: 'pending',
      );
      await _firestoreService.addTask(newTask);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$topic" has been added to your revision list!'))
        );
      }
    } else {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$topic" is already in your revision list.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Time Tables'),
      ),
      body: StreamBuilder<List<TimeTableModel>>(
        stream: _firestoreService.getTimeTablesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No time tables created yet.'));
          }
          
          final timetables = snapshot.data!;
          return PageView.builder(
            itemCount: timetables.length,
            itemBuilder: (context, index) {
              final timetable = timetables[index];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timetable.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                             PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteTimeTable(timetable.id!);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: timetable.slots.length,
                          itemBuilder: (context, slotIndex) {
                            final slot = timetable.slots[slotIndex];
                            final slotId = slot.id!;
                            final isCompleted = _completedSlots.contains(slotId);

                            return CheckboxListTile(
                              value: isCompleted,
                              onChanged: (bool? value) {
                                if (value == true) {
                                  setState(() => _completedSlots.add(slotId));
                                  _markSlotAsDone(slot.subject, slot.topic);
                                } else {
                                  setState(() => _completedSlots.remove(slotId));
                                }
                              },
                              title: Text(slot.topic, style: TextStyle(decoration: isCompleted ? TextDecoration.lineThrough : null)),
                              subtitle: Text(slot.subject),
                              secondary: CircleAvatar(child: Text(slot.subject.substring(0, 1).toUpperCase())),
                              controlAffinity: ListTileControlAffinity.trailing,
                            );
                          },
                        ),
                      ),
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
          context.push('/add-timetable');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
