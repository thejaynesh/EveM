import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/registration.dart';

class RegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'registrations';

  Future<void> registerForEvent(String eventId, String userId) async {
    final existingRegistration = await _firestore
        .collection(_collectionPath)
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existingRegistration.docs.isEmpty) {
      final newRegistration = Registration(
        id: '',
        eventId: eventId,
        userId: userId,
        registrationDate: DateTime.now(),
      );
      await _firestore
          .collection(_collectionPath)
          .add(newRegistration.toFirestore());
    } else {
      throw Exception('User is already registered for this event.');
    }
  }

  /// Checks if a user is already registered for a specific event.
  Future<bool> isRegistered({required String eventId, required String userId}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Stream<bool> isRegisteredStream({required String eventId, required String userId}) {
    return _firestore
        .collection(_collectionPath)
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Stream<List<Registration>> getUserRegistrations(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Registration.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> cancelRegistration(String registrationId) async {
    await _firestore.collection(_collectionPath).doc(registrationId).delete();
  }

  Stream<List<Registration>> getEventAttendees(String eventId) {
    return _firestore
        .collection(_collectionPath)
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Registration.fromFirestore(doc))
          .toList();
    });
  }

  Stream<Map<DateTime, int>> getDailyRegistrations() {
    // 1. Define the 7-day date range
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 6));

    // 2. Query Firestore for registrations within this range
    return _firestore
        .collection(_collectionPath)
        .where('registrationDate', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .map((snapshot) {
          // 3. Initialize a map with all 7 days having a count of 0
          final Map<DateTime, int> dailyCounts = {
            for (int i = 0; i <= 6; i++)
              startDate.add(Duration(days: i)): 0,
          };

          // 4. Populate the map with actual counts from Firestore
          for (var doc in snapshot.docs) {
            final registration = Registration.fromFirestore(doc);
            final registrationDay = DateTime(
              registration.registrationDate.year,
              registration.registrationDate.month,
              registration.registrationDate.day,
            );

            // Increment the count for the corresponding day
            if (dailyCounts.containsKey(registrationDay)) {
              dailyCounts[registrationDay] = dailyCounts[registrationDay]! + 1;
            }
          }
          return dailyCounts;
        });
  }
}
