import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/registration.dart';

class RegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerForEvent(Registration registration) async {
    await _firestore.collection('registrations').add(registration.toMap());
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
