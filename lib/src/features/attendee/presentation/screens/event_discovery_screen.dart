import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/event.dart';

class EventDiscoveryScreen extends StatefulWidget {
  const EventDiscoveryScreen({super.key});

  @override
  State<EventDiscoveryScreen> createState() => _EventDiscoveryScreenState();
}

class _EventDiscoveryScreenState extends State<EventDiscoveryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Events'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').where('isPublished', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          final allEvents = snapshot.data!.docs.map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>, id: doc.id)).toList();

          final filteredEvents = allEvents.where((event) {
            final titleLower = event.title.toLowerCase();
            final descriptionLower = event.description.toLowerCase();
            return titleLower.contains(_searchQuery) || descriptionLower.contains(_searchQuery);
          }).toList();

          if (filteredEvents.isEmpty) {
            return const Center(child: Text('No matching events found.'));
          }

          return ListView.builder(
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(event.title),
                  subtitle: Text('${event.date.toLocal().toString().split(' ')[0]} at ${event.time.format(context)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.go('/attendee-event-details/${event.id}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
