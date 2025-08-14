import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/event_management/data/event_service.dart';
import 'package:myapp/src/shared/models/event.dart';
import 'package:myapp/src/shared/models/registration.dart';
import 'package:myapp/src/features/attendee/data/registration_service.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegistrationService registrationService = RegistrationService();
    final EventService eventService = EventService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('Please log in to view your registrations.'),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
        ),
        child: StreamBuilder<List<Registration>>(
          stream: registrationService.getRegistrationsForAttendee(
            currentUser.uid,
          ),
          builder: (context, registrationSnapshot) {
            if (registrationSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (registrationSnapshot.hasError) {
              return Center(
                child: Text('Error: ${registrationSnapshot.error}'),
              );
            }
            if (!registrationSnapshot.hasData ||
                registrationSnapshot.data!.isEmpty) {
              return const Center(child: Text('No registrations found.'));
            }

            final registrations = registrationSnapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Mobile view (ListView)
                  return ListView.builder(
                    itemCount: registrations.length,
                    itemBuilder: (context, index) {
                      final registration = registrations[index];
                      return FutureBuilder<Event?>(
                        future: eventService.getEventById(registration.eventId),
                        builder: (context, eventSnapshot) {
                          if (eventSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Loading event...'),
                            );
                          }
                          if (eventSnapshot.hasError) {
                            return ListTile(
                              title: Text(
                                'Error loading event: ${eventSnapshot.error}',
                              ),
                            );
                          }
                          if (!eventSnapshot.hasData ||
                              eventSnapshot.data == null) {
                            return const ListTile(
                              title: Text('Event not found.'),
                            );
                          }

                          final event = eventSnapshot.data!;
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: const Icon(Icons.event_note),
                              title: Text(event.title),
                              subtitle: Text(
                                'Registered on: ${registration.registrationDate.toLocal().toString().split(' ')[0]}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () async {
                                  try {
                                    await registrationService.cancelRegistration(registration.id!);
                                    if (!context.mounted) return;
                                    // Optionally, show a confirmation message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Registration cancelled successfully!'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                },
                              ),
                              onTap: () {
                                context.go(
                                  '/attendee/event-details/${event.id}',
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  // Web/Desktop view (GridView)
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns for wider screens
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio:
                          3 / 1, // Adjust aspect ratio as needed
                    ),
                    itemCount: registrations.length,
                    itemBuilder: (context, index) {
                      final registration = registrations[index];
                      return FutureBuilder<Event?>(
                        future: eventService.getEventById(registration.eventId),
                        builder: (context, eventSnapshot) {
                          if (eventSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (eventSnapshot.hasError) {
                            return Card(
                              child: Center(
                                child: Text(
                                  'Error loading event: ${eventSnapshot.error}',
                                ),
                              ),
                            );
                          }
                          if (!eventSnapshot.hasData ||
                              eventSnapshot.data == null) {
                            return const Card(
                              child: Center(child: Text('Event not found.')),
                            );
                          }

                          final event = eventSnapshot.data!;
                          return Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: InkWell(
                              onTap: () {
                                context.go(
                                  '/attendee/event-details/${event.id}',
                                );
                              },
                              borderRadius: BorderRadius.circular(12.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      event.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      'Registered on: ${registration.registrationDate.toLocal().toString().split(' ')[0]}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ), // Corrected closing parenthesis
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
