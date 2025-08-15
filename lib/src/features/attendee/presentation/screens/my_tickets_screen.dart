import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/registration_service.dart';
import '../../../event_management/data/event_service.dart';
import '../../../../shared/models/registration.dart';
import '../../../../shared/models/event.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(
        child: Text('Please log in to see your tickets.'),
      );
    }

    final registrationService = Provider.of<RegistrationService>(context);
    final eventService = Provider.of<EventService>(context);

    return Scaffold(
      body: StreamBuilder<List<Registration>>(
        stream: registrationService.getUserRegistrations(currentUser.uid),
        builder: (context, registrationSnapshot) {
          if (registrationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (registrationSnapshot.hasError) {
            return Center(child: Text('Error: ${registrationSnapshot.error}'));
          }
          if (!registrationSnapshot.hasData || registrationSnapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Tickets Yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You haven\'t registered for any events.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final registrations = registrationSnapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index];
              return FutureBuilder<Event?>(
                future: eventService.getEventById(registration.eventId),
                builder: (context, eventSnapshot) {
                  if (eventSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const _TicketCardPlaceholder();
                  }
                  if (eventSnapshot.hasError || !eventSnapshot.hasData) {
                    return Card(
                      child: ListTile(
                        title: const Text('Event not found'),
                        subtitle: Text('Event ID: ${registration.eventId}'),
                      ),
                    );
                  }

                  final event = eventSnapshot.data!;
                  return _TicketCard(event: event, registration: registration);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.event, required this.registration});

  final Event event;
  final Registration registration;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => context.go('/attendee/event-details/${event.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
              child: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  ? Image.network(
                      event.imageUrl!,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                          ),
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.event, size: 100, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    text: event.startDate != null
                        ? DateFormat.yMMMMEEEEd().format(event.startDate!)
                        : 'Date TBA',
                  ),
                  const SizedBox(height: 4.0),
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on,
                    text: event.location,
                  ),
                  const SizedBox(height: 12.0),
                  const Divider(),
                  const SizedBox(height: 12.0),
                  _buildInfoRow(
                    context,
                    icon: Icons.confirmation_number,
                    text: 'Registration ID: ${registration.id}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TicketCardPlaceholder extends StatelessWidget {
  const _TicketCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 200,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8.0),
                Container(
                  height: 16,
                  width: 150,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 4.0),
                Container(
                  height: 16,
                  width: 100,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
