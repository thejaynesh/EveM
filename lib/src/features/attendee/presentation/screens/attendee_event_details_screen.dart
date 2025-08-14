import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/event.dart';
import '../../../../shared/models/registration.dart';
import '../../data/registration_service.dart';
import '../../../../shared/widgets/attendee_scaffold.dart';
import '../../../../shared/widgets/public_scaffold.dart';
import 'package:intl/intl.dart';

class AttendeeEventDetailsScreen extends StatelessWidget {
  final String eventId;

  const AttendeeEventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final RegistrationService registrationService = RegistrationService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    Widget content = StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .snapshots(),
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

        final event = Event.fromMap(
          snapshot.data!.data() as Map<String, dynamic>,
          id: snapshot.data!.id,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.imageUrl != null)
                Image.network(
                  event.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ) else Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              Text(
                event.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('MMMM d, yyyy').format(event.date.toLocal())} at ${event.time.format(context)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (event.endDateTime != null)
                Text(
                  'End Date: ${DateFormat('MMMM d, yyyy').format(event.endDateTime!.toLocal())}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 16),
              Text(event.description),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (currentUser != null) {
                    final newRegistration = Registration(
                      eventId: event.id!,
                      attendeeId: currentUser.uid,
                      registrationDate: DateTime.now(),
                    );
                    try {
                      await registrationService.registerForEvent(
                        newRegistration,
                      );
                      // Check if the widget is still mounted before using context
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Successfully registered for the event!',
                          ),
                        ),
                      );
                      // Check if the widget is still mounted before using context
                      if (!context.mounted) return;
                      context.pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                        ),
                      );
                    }
                  } else {
                    if (!context.mounted) return; // Add mounted check
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You must be logged in to register.'),
                      ),
                    );
                  }
                },
                child: const Text('Register for this Event'),
              ),
            ],
          ),
        );
      },
    );

    // Conditionally return either AttendeeScaffold or PublicScaffold
    if (currentUser != null) {
      return AttendeeScaffold(child: content);
    } else {
      return PublicScaffold(child: content);
    }
  }
}
