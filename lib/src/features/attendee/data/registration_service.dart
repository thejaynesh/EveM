import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/registration.dart';

class RegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isAlreadyRegistered(String attendeeId, String eventId) async {
    final QuerySnapshot result = await _firestore
        .collection('registrations')
        .where('attendeeId', isEqualTo: attendeeId)
        .where('eventId', isEqualTo: eventId)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<void> registerForEvent(Registration registration) async {
    final bool alreadyRegistered = await isAlreadyRegistered(
      registration.attendeeId,
      registration.eventId,
    );

    if (alreadyRegistered) {
      throw Exception('You are already registered for this event.');
    }
    await _firestore.collection('registrations').add(registration.toMap());
  }

  Future<void> cancelRegistration(String registrationId) async {
    await _firestore.collection('registrations').doc(registrationId).delete();
  }

  Stream<List<Registration>> getRegistrationsForAttendee(String attendeeId) {
    return _firestore
        .collection('registrations')
        .where('attendeeId', isEqualTo: attendeeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Registration.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }
}
