import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../shared/models/event.dart';
import '../../../../shared/models/task.dart';
import '../../data/event_service.dart';
import '../../data/task_service.dart';
import 'add_task_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final eventService = Provider.of<EventService>(context);
    final taskService = Provider.of<TaskService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/manager/edit-event/$eventId');
            },
          ),
          IconButton(
            icon: const Icon(Icons.attach_money),
            onPressed: () {
              context.go('/manager/budget/$eventId');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, eventService, eventId),
          ),
        ],
      ),
      body: StreamBuilder<Event?>(
        stream: eventService.getEvent(eventId),
        builder: (context, eventSnapshot) {
          if (eventSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (eventSnapshot.hasError) {
            return Center(child: Text('Error: ${eventSnapshot.error}'));
          }
          if (!eventSnapshot.hasData || eventSnapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }

          final event = eventSnapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${event.startDate?.toLocal()} - ${event.endDate?.toLocal()}',
                ),
                const SizedBox(height: 8),
                Text('Location: ${event.location}'),
                const SizedBox(height: 16),
                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                StreamBuilder<List<Task>>(
                  stream: taskService.getTasksForEvent(eventId),
                  builder: (context, taskSnapshot) {
                    if (taskSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (taskSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${taskSnapshot.error}'));
                    }
                    if (!taskSnapshot.hasData || taskSnapshot.data!.isEmpty) {
                      return const Center(child: Text('No tasks for this event.'));
                    }

                    final tasks = taskSnapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(task.description),
                          trailing: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) {
                              taskService.updateTask(
                                task.copyWith(isCompleted: value),
                              );
                            },
                          ),
                          onLongPress: () {
                            taskService.deleteTask(task.id!);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(eventId: eventId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, EventService eventService, String eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                eventService.deleteEvent(eventId).then((_) {
                  Navigator.of(context).pop(); // Dismiss dialog
                  context.pop(); // Go back from event details
                }).catchError((error) {
                   Navigator.of(context).pop();
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Error deleting event: $error'))
                   );
                });
              },
            ),
          ],
        );
      },
    );
  }
}
