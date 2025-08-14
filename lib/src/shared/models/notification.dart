import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String? id;
  final String eventId;
  final String title;
  final String message;
  final DateTime timestamp;

  Notification({
    this.id,
    required this.eventId,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map, {String? id}) {
    return Notification(
      id: id,
      eventId: map['eventId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
