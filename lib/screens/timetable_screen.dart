import 'package:chetegram/models/timetable_model.dart';
import 'package:chetegram/services/firestore_service.dart'; // FirestoreService इम्पोर्ट करें
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _deleteTimeTable(String id) async {
    // DatabaseHelper की जगह FirestoreService का उपयोग करें
    await _firestoreService.deleteTimeTable(id);
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time Table Deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Time Tables'),
      ),
      body: StreamBuilder<List<TimeTableModel>>( // FutureBuilder को StreamBuilder से बदलें
        stream: _firestoreService.getTimeTablesStream(), // stream का उपयोग करें
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
                            return ListTile(
                              leading: CircleAvatar(child: Text(slot.subject.substring(0, 1).toUpperCase())),
                              title: Text(slot.subject),
                              subtitle: Text(slot.frequency),
                              trailing: Text(
                                '${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                              ),
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
          // अब .then() की ज़रूरत नहीं है क्योंकि StreamBuilder अपने आप UI अपडेट कर देगा
          context.push('/add-timetable');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
