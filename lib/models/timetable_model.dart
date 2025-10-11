import 'package:chetegram/models/time_slot_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeTableModel {
  final String? id;
  final String title;
  final List<TimeSlotModel> slots;

  TimeTableModel({
    this.id,
    required this.title,
    this.slots = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
    };
  }

  factory TimeTableModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TimeTableModel(
      id: doc.id,
      title: data['title'] ?? '',
    );
  }
}
