import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/models/event.dart';
import '../../../event_management/data/event_service.dart';

class EventsOverview extends StatelessWidget {
  const EventsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: Provider.of<EventService>(context).getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No events found.'));
        }

        final events = snapshot.data!;

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: event.imageUrl != null && event.imageUrl!.isNotEmpty
                    ? Image.network(event.imageUrl!,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.event, size: 50),
                title: Text(event.name),
                subtitle: Text(
                    '${event.location} - ${event.startDate?.toLocal().toString().split(' ')[0] ?? 'TBA'}'),
                onTap: () {
                  context.go('/manager/event-details/${event.id}');
                },
              ),
            );
          },
        );
      },
    );
  }
}
