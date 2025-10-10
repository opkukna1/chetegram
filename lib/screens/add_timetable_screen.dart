import 'package:chetegram/models/time_slot_model.dart';
import 'package:chetegram/models/timetable_model.dart';
import 'package:chetegram/services/firestore_service.dart'; // FirestoreService इम्पोर्ट करें
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
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _saveTimeTable() async {
    if (_formKey.currentState!.validate()) {
      final timetable = TimeTableModel(title: _titleController.text);
      
      List<TimeSlotModel> slotModels = [];
      for (var slotState in _slots) {
        if (slotState.subjectController.text.isNotEmpty && slotState.startTime != null && slotState.endTime != null) {
          slotModels.add(TimeSlotModel(
            subject: slotState.subjectController.text,
            startTime: slotState.startTime!,
            endTime: slotState.endTime!,
            frequency: slotState.frequency,
          ));
        }
      }

      if (slotModels.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one valid time slot.')));
        return
  }
}
