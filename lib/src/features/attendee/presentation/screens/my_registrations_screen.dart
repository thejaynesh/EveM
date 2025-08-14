import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/event_management/data/event_service.dart';
import 'package:myapp/src/shared/models/event.dart';
import 'package:myapp/src/shared/models/registration.dart';
import 'package:myapp/src/features/attendee/data/registration_service.dart';

class MyRegistrationsScreen extends StatelessWidget {
  const MyRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegistrationService registrationService = RegistrationService();
    final EventService eventService = EventService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view your registrations.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Registrations'),
      ),
      body: StreamBuilder<List<Registration>>(
        stream: registrationService.getRegistrationsForAttendee(currentUser.uid),
        builder: (context, registrationSnapshot) {
          if (registrationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (registrationSnapshot.hasError) {
            return Center(child: Text('Error: ${registrationSnapshot.error}'));
          }
          if (!registrationSnapshot.hasData || registrationSnapshot.data!.isEmpty) {
            return const Center(child: Text('No registrations found.'));
          }

          final registrations = registrationSnapshot.data!;

          return ListView.builder(
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              return FutureBuilder<Event?>(
                future: eventService.getEventById(registration.eventId),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading event...'));
                  }
                  if (eventSnapshot.hasError) {
                    return ListTile(title: Text('Error loading event: ${eventSnapshot.error}'));
                  }
                  if (!eventSnapshot.hasData || eventSnapshot.data == null) {
                    return const ListTile(title: Text('Event not found.'));
                  }

                  final event = eventSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.event_note),
                      title: Text(event.title),
                      subtitle: Text(
                          'Registered on: ${registration.registrationDate.toLocal().toString().split(' ')[0]}'),
                      onTap: () {
                        context.go('/attendee-event-details/${event.id}');
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
