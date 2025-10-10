import 'package:flutter/material.dart';

class TimeSlotModel {
  final int? id;
  final int timetableId;
  final String subject;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String frequency;

  TimeSlotModel({
    this.id,
    required this.timetableId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timetableId': timetableId,
      'subject': subject,
      // TimeOfDay को मिनटों में स्टोर करेंगे
      'startTimeMinutes': startTime.hour * 60 + startTime.minute,
      'endTimeMinutes': endTime.hour * 60 + endTime.minute,
      'frequency': frequency,
    };
  }

  factory TimeSlotModel.fromMap(Map<String, dynamic> map) {
    return TimeSlotModel(
      id: map['id'],
      timetableId: map['timetableId'],
      subject: map['subject'],
      // मिनटों को वापस TimeOfDay में बदलेंगे
      startTime: TimeOfDay(hour: map['startTimeMinutes'] ~/ 60, minute: map['startTimeMinutes'] % 60),
      endTime: TimeOfDay(hour: map['endTimeMinutes'] ~/ 60, minute: map['endTimeMinutes'] % 60),
      frequency: map['frequency'],
    );
  }
}
