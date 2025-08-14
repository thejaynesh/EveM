import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Event>> getEventsForManager(String managerId) {
    return _firestore
        .collection('events')
        .where('managerId', isEqualTo: managerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Event.fromMap(doc.data(), id: doc.id);
          }).toList();
        });
  }

  Future<Event?> getEventById(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return Event.fromMap(doc.data()!, id: doc.id);
    } else {
      return null;
    }
  }

  Future<void> addEvent(Event event) async {
    if (_auth.currentUser != null) {
      final eventWithManagerId = event.copyWith(
        managerId: _auth.currentUser!.uid,
      );
      await _firestore.collection('events').add(eventWithManagerId.toMap());
    }
  }

  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }
}
