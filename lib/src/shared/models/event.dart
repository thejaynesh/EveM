import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

class Event {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imageUrl;
  final bool isPublished;

  Event({
    this.id = '',
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.isPublished = false,
  });

  Event copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    bool? isPublished,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  /// A completely safe factory for creating an Event from a Firestore document.
  /// This method will not throw a TypeError, even with malformed data.
  factory Event.fromFirestore(DocumentSnapshot doc) {
    // Ensure data is a map, even if the document is empty.
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Helper function to safely get a value of a specific type.
    T? safeGet<T>(String key) {
      if (data.containsKey(key) && data[key] is T) {
        return data[key] as T;
      }
      return null;
    }

    try {
      final name = safeGet<String>('name') ?? 'No Name Provided';
      final description = safeGet<String>('description') ?? 'No Description';
      final location = safeGet<String>('location') ?? 'No Location';
      final imageUrl = safeGet<String>('imageUrl');

      final startDateTimestamp = safeGet<Timestamp>('startDate');
      final startDate = startDateTimestamp?.toDate();

      final endDateTimestamp = safeGet<Timestamp>('endDate');
      final endDate = endDateTimestamp?.toDate();

      final isPublished = safeGet<bool>('isPublished') ?? false;

      return Event(
        id: doc.id,
        name: name,
        description: description,
        location: location,
        startDate: startDate,
        endDate: endDate,
        imageUrl: imageUrl,
        isPublished: isPublished,
      );
    } catch (e, stackTrace) {
      developer.log(
        '!!!!!!!! UNEXPECTED PARSING ERROR for doc ${doc.id} !!!!!!!!',
        name: 'Event.fromFirestore',
        error: e,
        stackTrace: stackTrace,
      );
      // Return a visible "error" event instead of crashing the app.
      return Event(
        id: doc.id,
        name: 'Error: Invalid Event Data',
        description: 'This event could not be loaded. Please check data format.',
        location: 'Unknown',
        startDate: null,
        endDate: null,
        isPublished: false, // Ensure it doesn't show up if there's an error.
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'imageUrl': imageUrl,
      'isPublished': isPublished,
    };
  }
}
