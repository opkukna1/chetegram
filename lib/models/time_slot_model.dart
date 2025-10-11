import 'package:flutter/material.dart';

class TimeSlotModel {
  final String? id;
  final String subject;
  final String topic; // नया फील्ड
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String frequency;

  TimeSlotModel({
    this.id,
    required this.subject,
    required this.topic, // कंस्ट्रक्टर में जोड़ा गया
    required this.startTime,
    required this.endTime,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'topic': topic, // toMap में जोड़ा गया
      'startTimeMinutes': startTime.hour * 60 + startTime.minute,
      'endTimeMinutes': endTime.hour * 60 + endTime.minute,
      'frequency': frequency,
    };
  }

  factory TimeSlotModel.fromFirestore(Map<String, dynamic> map, String id) {
    return TimeSlotModel(
      id: id,
      subject: map['subject'] ?? '',
      topic: map['topic'] ?? '', // fromFirestore में जोड़ा गया
      startTime: TimeOfDay(hour: (map['startTimeMinutes'] ?? 0) ~/ 60, minute: (map['startTimeMinutes'] ?? 0) % 60),
      endTime: TimeOfDay(hour: (map['endTimeMinutes'] ?? 0) ~/ 60, minute: (map['endTimeMinutes'] ?? 0) % 60),
      frequency: map['frequency'] ?? 'Daily',
    );
  }
}
