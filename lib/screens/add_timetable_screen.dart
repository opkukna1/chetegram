import 'package:chetegram/models/time_slot_model.dart';
import 'package:chetegram/models/timetable_model.dart';
import 'package:chetegram/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// यह एक छोटा मॉडल है जो सिर्फ इस स्क्रीन की State को मैनेज करने के लिए है
class TimeSlotState {
  TextEditingController subjectController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String frequency = 'Daily';
}

class AddTimeTableScreen extends StatefulWidget {
  const AddTimeTableScreen({super.key});

  @override
  State<AddTimeTableScreen> createState() => _AddTimeTableScreenState();
}

class _AddTimeTableScreenState extends State<AddTimeTableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  List<TimeSlotState> _slots = [TimeSlotState()]; // शुरुआत में एक स्लॉट

  Future<void> _saveTimeTable() async {
    if (_formKey.currentState!.validate()) {
      // 1. टाइम टेबल का टाइटल सेव करें
      final timetable = TimeTableModel(title: _titleController.text);
      
      // 2. सभी स्लॉट्स का डेटा तैयार करें
      List<Map<String, dynamic>> slotMaps = [];
      for (var slotState in _slots) {
        if (slotState.subjectController.text.isNotEmpty && slotState.startTime != null && slotState.endTime != null) {
          slotMaps.add(TimeSlotModel(
            timetableId: 0, // ID डेटाबेस में अपने आप बन जाएगा
            subject: slotState.subjectController.text,
            startTime: slotState.startTime!,
            endTime: slotState.endTime!,
            frequency: slotState.frequency,
          ).toMap());
        }
      }

      if (slotMaps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one valid time slot.')));
        return;
      }

      // 3. डेटाबेस में सेव करें
      await DatabaseHelper.instance.insertTimeTableWithSlots(timetable, slotMaps);

      if (mounted) {
        context.pop();
      }
    }
  }

  void _addSlot() {
    setState(() {
      _slots.add(TimeSlotState());
    });
  }

  void _removeSlot(int index) {
    setState(() {
      _slots.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Time Table'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTimeTable,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Time Table Title',
                  hintText: 'e.g., Weekday Study Plan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _slots.length,
                  itemBuilder: (context, index) {
                    return _buildSlotCard(index);
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addSlot,
                icon: const Icon(Icons.add),
                label: const Text('Add another Slot'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard(int index) {
    final slot = _slots[index];
    final String startTimeText = slot.startTime?.format(context) ?? 'Start Time';
    final String endTimeText = slot.endTime?.format(context) ?? 'End Time';
    
    // Duration की गणना
    String durationText = '';
    if (slot.startTime != null && slot.endTime != null) {
      final startMinutes = slot.startTime!.hour * 60 + slot.startTime!.minute;
      final endMinutes = slot.endTime!.hour * 60 + slot.endTime!.minute;
      final duration = endMinutes - startMinutes;
      if (duration > 0) {
        final hours = duration ~/ 60;
        final minutes = duration % 60;
        durationText = '${hours}h ${minutes}m';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Slot #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_slots.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeSlot(index),
                  )
              ],
            ),
            TextFormField(
              controller: slot.subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
              validator: (v) => v!.isEmpty ? 'Subject is required' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) setState(() => slot.startTime = time);
                    },
                    child: Text(startTimeText),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) setState(() => slot.endTime = time);
                    },
                    child: Text(endTimeText),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 10),
            Row(
              children: [
                const Text('Frequency: '),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: slot.frequency,
                    items: ['Daily', 'Weekdays', 'Weekends', 'Once a week']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => slot.frequency = value);
                    },
                  ),
                ),
                if (durationText.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text('Duration: $durationText', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
