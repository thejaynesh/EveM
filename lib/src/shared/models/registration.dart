import 'package:cloud_firestore/cloud_firestore.dart';

class Registration {
  final String id;
  final String eventId;
  final String userId;
  final DateTime registrationDate;

  Registration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registrationDate,
  });

  factory Registration.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Registration(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      registrationDate: (data['registrationDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registrationDate': Timestamp.fromDate(registrationDate),
    };
  }
}
