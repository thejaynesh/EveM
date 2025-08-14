import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? endDateTime;
  final TimeOfDay time;
  final String? managerId;
  final bool isPublished; // New field
  final String? imageUrl; // New field
  final String? organizerName; // New field

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.endDateTime,
    required this.time,
    this.managerId,
    this.isPublished = false, // Default to not published
    this.imageUrl,
    this.organizerName,
  });

  // Convert a Event object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'endDateTime': endDateTime != null ? Timestamp.fromDate(endDateTime!) : null,
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'managerId': managerId,
      'isPublished': isPublished,
      'imageUrl': imageUrl,
      'organizerName': organizerName,
    };
  }

  // Convert a Map object into a Event object
  factory Event.fromMap(Map<String, dynamic> map, {String? id}) {
    // Helper to parse time string safely
    TimeOfDay parseTime(String timeStr) {
      try {
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        return TimeOfDay.now(); // Default value
      }
    }

    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      endDateTime: map['endDateTime'] != null ? (map['endDateTime'] as Timestamp).toDate() : null,
      time: parseTime(map['time'] ?? '00:00'),
      managerId: map['managerId'] ?? '',
      isPublished: map['isPublished'] ?? false,
      imageUrl: map['imageUrl'] ?? null,
      organizerName: map['organizerName'] ?? null,
    );
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? endDateTime,
    TimeOfDay? time,
    String? managerId,
    bool? isPublished,
    String? imageUrl,
    String? organizerName,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      endDateTime: endDateTime ?? this.endDateTime,
      time: time ?? this.time,
      managerId: managerId ?? this.managerId,
      isPublished: isPublished ?? this.isPublished,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerName: organizerName ?? this.organizerName,
    );
  }
}
