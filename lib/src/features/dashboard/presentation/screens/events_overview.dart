import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../event_management/data/event_service.dart';
import '../../../event_management/presentation/screens/event_details_screen.dart'; // Import EventDetailsScreen
import '../../../../shared/models/event.dart'; // Import Event model

class EventsOverview extends StatelessWidget {
  const EventsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final EventService eventService = EventService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view your events.'));
    }

    return StreamBuilder<List<Event>>(
      stream: eventService.getEventsForManager(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events found. Start by adding a new event!'));
        }

        final events = snapshot.data!;
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(event: event);
          },
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Text('${event.date.toLocal().toString().split(' ')[0]} at ${event.time.format(context)}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          context.go('/event-details/${event.id}');
        },
      ),
    );
  }
}
