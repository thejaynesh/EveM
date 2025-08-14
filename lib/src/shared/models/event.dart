import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String? managerId;
  final bool isPublished; // New field

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.managerId,
    this.isPublished = false, // Default to not published
  });

  // Convert a Event object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', // Store time as a string H:mm
      'managerId': managerId,
      'isPublished': isPublished,
    };
  }

  // Convert a Map object into a Event object
  factory Event.fromMap(Map<String, dynamic> map, {String? id}) {
    // Helper to parse time string safely
    TimeOfDay parseTime(String timeStr) {
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        return TimeOfDay.now(); // Default value
      }
    }

    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: parseTime(map['time'] ?? '00:00'),
      managerId: map['managerId'] ?? '',
      isPublished: map['isPublished'] ?? false,
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    String? managerId,
    bool? isPublished,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      managerId: managerId ?? this.managerId,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
