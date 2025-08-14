import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.eventId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      eventId: map['eventId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
    );
  }

  Task copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
