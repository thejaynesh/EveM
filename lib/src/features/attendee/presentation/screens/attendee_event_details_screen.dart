import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/models/event.dart';
import '../../../event_management/data/event_service.dart';
import '../../data/registration_service.dart';

class AttendeeEventDetailsScreen extends StatelessWidget {
  final String eventId;

  const AttendeeEventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final registrationService =
        Provider.of<RegistrationService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: StreamBuilder<Event?>(
        stream: Provider.of<EventService>(context, listen: false)
            .getEvent(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      event.imageUrl!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 250,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                          ),
                    ),
                  )
                else
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Icon(Icons.event, size: 100, color: Colors.grey),
                  ),
                const SizedBox(height: 24),
                Text(
                  event.name,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Start Date',
                  value: event.startDate != null
                      ? DateFormat.yMMMMEEEEd().add_jm().format(event.startDate!)
                      : 'TBA',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_today_outlined,
                  label: 'End Date',
                  value: event.endDate != null
                      ? DateFormat.yMMMMEEEEd().add_jm().format(event.endDate!)
                      : 'TBA',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on,
                  label: 'Location',
                  value: event.location,
                ),
                const SizedBox(height: 24),
                Text(
                  'About this event',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                if (user != null)
                  StreamBuilder<bool>(
                    stream: registrationService.isRegisteredStream(eventId: eventId, userId: user.uid),
                    builder: (context, registrationSnapshot) {
                      if (registrationSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final isRegistered = registrationSnapshot.data ?? false;

                      return Center(
                        child: isRegistered
                            ? const Chip(
                                avatar: Icon(Icons.check_circle, color: Colors.white),
                                label: Text('You are registered'),
                                backgroundColor: Colors.green,
                                labelStyle: TextStyle(color: Colors.white),
                              )
                            : ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await registrationService.registerForEvent(
                                        event.id, user.uid);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Successfully registered for ${event.name}!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error registering: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text('Register for this Event'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 16.0),
                                  textStyle: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                      );
                    },
                  )
                else
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/attendee/login'),
                      icon: const Icon(Icons.login),
                      label: const Text('Login to Register'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
