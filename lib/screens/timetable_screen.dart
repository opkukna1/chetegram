import 'package:chetegram/models/timetable_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  late Future<List<TimeTableModel>> _timetablesFuture;

  @override
  void initState() {
    super.initState();
    _refreshTimeTables();
  }

  void _refreshTimeTables() {
    setState(() {
      _timetablesFuture = DatabaseHelper.instance.getAllTimeTablesWithSlots();
    });
  }

  void _deleteTimeTable(int id) async {
    await DatabaseHelper.instance.deleteTimeTable(id);
    _refreshTimeTables();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time Table Deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Time Tables'),
      ),
      body: FutureBuilder<List<TimeTableModel>>(
        future: _timetablesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No time tables created yet.'));
          }
          final timetables = snapshot.data!;
          // PageView का उपयोग करके स्वाइप करने वाला फीचर
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
                        padding: const EdgeInsets.all(16.0),
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
                                // Edit का लॉजिक बाद में जोड़ा जाएगा
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
                              leading: CircleAvatar(child: Text(slot.subject.substring(0, 1))),
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
          context.push('/add-timetable').then((_) => _refreshTimeTables());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
