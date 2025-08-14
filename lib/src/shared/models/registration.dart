import 'package:cloud_firestore/cloud_firestore.dart';

class Registration {
  final String? id;
  final String eventId;
  final String attendeeId;
  final DateTime registrationDate;

  Registration({
    this.id,
    required this.eventId,
    required this.attendeeId,
    required this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'attendeeId': attendeeId,
      'registrationDate': Timestamp.fromDate(registrationDate),
    };
  }

  factory Registration.fromMap(Map<String, dynamic> map, {String? id}) {
    return Registration(
      id: id,
      eventId: map['eventId'] ?? '',
      attendeeId: map['attendeeId'] ?? '',
      registrationDate: (map['registrationDate'] as Timestamp).toDate(),
    );
  }
}
