import 'package:chetegram/models/time_slot_model.dart';

class TimeTableModel {
  final int? id;
  final String title;
  final List<TimeSlotModel> slots;

  TimeTableModel({
    this.id,
    required this.title,
    this.slots = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory TimeTableModel.fromMap(Map<String, dynamic> map) {
    return TimeTableModel(
      id: map['id'],
      title: map['title'],
    );
  }
}
