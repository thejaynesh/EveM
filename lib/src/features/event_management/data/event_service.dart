import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../../shared/models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'events';

  Future<DocumentReference> addEvent(Event event) async {
    // Ensure new events are published by default
    final eventWithDefaults = event.copyWith(isPublished: true);
    return await _firestore.collection(_collectionPath).add(eventWithDefaults.toFirestore());
  }


  /// Fetches only the events that are marked as published.
  Stream<List<Event>> getEvents() {
    developer.log('Fetching PUBLISHED events from Firestore...', name: 'EventService.getEvents');
    return _firestore
        .collection(_collectionPath)
        .where('isPublished', isEqualTo: true) // This is the critical fix
        .snapshots()
        .map((snapshot) {
      developer.log('Received snapshot with ${snapshot.docs.length} published documents.', name: 'EventService.getEvents');
      if (snapshot.docs.isEmpty) {
        developer.log('No published events found.', name: 'EventService.getEvents');
        return <Event>[];
      }
      try {
        final events = snapshot.docs.map((doc) {
          developer.log('Attempting to parse document: ${doc.id}', name: 'EventService.getEvents');
          return Event.fromFirestore(doc);
        }).toList();
        developer.log('Successfully parsed ${events.length} published events.', name: 'EventService.getEvents');
        return events;
      } catch (e, stackTrace) {
        developer.log(
          'Error mapping snapshot to events',
          name: 'EventService.getEvents',
          error: e,
          stackTrace: stackTrace,
        );
        return <Event>[];
      }
    });
  }


  Future<void> updateEvent(Event event) async {
    await _firestore
        .collection(_collectionPath)
        .doc(event.id)
        .update(event.toFirestore());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collectionPath).doc(eventId).delete();
  }

  Stream<Event?> getEvent(String eventId) {
    return _firestore
        .collection(_collectionPath)
        .doc(eventId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Event.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionPath).doc(eventId).get();
      if (docSnapshot.exists) {
        return Event.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      developer.log('Error fetching event by ID: $e', name: 'EventService.getEventById');
      return null;
    }
  }
}
