import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/event.dart';
import '../../../../shared/models/registration.dart';
import '../../data/registration_service.dart';

class AttendeeEventDetailsScreen extends StatelessWidget {
  final String eventId;

  const AttendeeEventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final RegistrationService registrationService = RegistrationService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('events').doc(eventId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Event not found.'));
          }

          final event = Event.fromMap(snapshot.data!.data() as Map<String, dynamic>, id: snapshot.data!.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${event.date.toLocal().toString().split(' ')[0]} at ${event.time.format(context)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  event.description,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (currentUser != null) {
                      final newRegistration = Registration(
                        eventId: event.id!,
                        attendeeId: currentUser.uid,
                        registrationDate: DateTime.now(),
                      );
                      await registrationService.registerForEvent(newRegistration);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Successfully registered for the event!')),
                      );
                      context.pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You must be logged in to register.')),
                      );
                    }
                  },
                  child: const Text('Register for this Event'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
