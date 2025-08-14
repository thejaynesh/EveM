import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/event.dart';
import '../../data/budget_service.dart';
import '../../data/collaborator_service.dart';
import '../../data/task_service.dart';
import '../../../../shared/models/budget.dart';
import '../../../../shared/models/collaborator.dart';
import '../../../../shared/models/task.dart';
import '../../../../shared/models/notification.dart' as app_notification;
import '../../../attendee/data/notification_service.dart';

class EventDetailsScreen extends StatelessWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                final event = Event.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>,
                  id: snapshot.data!.id,
                );
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.go('/edit-event', extra: event);
                  },
                );
              }
              return Container();
            },
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _showSendNotificationDialog(context, eventId);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ), // Max width for web/desktop
              child: SingleChildScrollView(
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
                    Text(event.description),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Budget'),
                    BudgetSummary(eventId: eventId),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Tasks'),
                    TaskList(eventId: eventId),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Collaborators'),
                    CollaboratorList(eventId: eventId),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context, String eventId) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newNotification = app_notification.Notification(
                  eventId: eventId,
                  title: titleController.text,
                  message: messageController.text,
                  timestamp: DateTime.now(),
                );
                await NotificationService().sendNotification(newNotification);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification Sent!')),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class BudgetSummary extends StatelessWidget {
  final String eventId;
  const BudgetSummary({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final BudgetService budgetService = BudgetService();

    return StreamBuilder<Budget?>(
      stream: budgetService.getBudgetForEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final budget = snapshot.data;
        final totalBudget = budget?.totalBudget ?? 0.0;
        final totalSpent = budget?.totalSpent ?? 0.0;
        final progress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Budget:'),
                    Text('\$${totalBudget.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Spent:'),
                    Text('\$${totalSpent.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      _showBudgetDialog(context, budget);
                    },
                    child: const Text('Set Budget'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBudgetDialog(BuildContext context, Budget? currentBudget) {
    final TextEditingController totalBudgetController = TextEditingController(
      text: currentBudget?.totalBudget.toString() ?? '',
    );
    final TextEditingController totalSpentController = TextEditingController(
      text: currentBudget?.totalSpent.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: totalBudgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Budget'),
              ),
              TextField(
                controller: totalSpentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Spent'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTotalBudget =
                    double.tryParse(totalBudgetController.text) ?? 0.0;
                final newTotalSpent =
                    double.tryParse(totalSpentController.text) ?? 0.0;

                final budget = Budget(
                  id: currentBudget!.id,
                  eventId: eventId,
                  totalBudget: newTotalBudget,
                  totalSpent: newTotalSpent,
                );
                await BudgetService().setBudget(budget);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class TaskList extends StatelessWidget {
  final String eventId;
  const TaskList({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final TaskService taskService = TaskService();

    return StreamBuilder<List<Task>>(
      stream: taskService.getTasksForEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final tasks = snapshot.data ?? [];
        final completedTasks = tasks.where((task) => task.isCompleted).toList();
        final incompleteTasks = tasks
            .where((task) => !task.isCompleted)
            .toList();

        return Card(
          child: Column(
            children: [
              ...incompleteTasks.map(
                (task) => _buildTaskTile(context, task, taskService),
              ),
              ...completedTasks.map(
                (task) => _buildTaskTile(context, task, taskService),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Task'),
                onTap: () {
                  _showAddTaskDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    Task task,
    TaskService taskService,
  ) {
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
        onChanged: (value) async {
          await taskService.updateTask(task.copyWith(isCompleted: value));
        },
      ),
      onLongPress: () async {
        // Option to delete task
        await taskService.deleteTask(task.id);
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTask = Task(
                  id: '', // ID will be generated by Firestore
                  eventId: eventId,
                  title: titleController.text,
                  description: descriptionController.text,
                );
                await TaskService().addTask(newTask);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class CollaboratorList extends StatelessWidget {
  final String eventId;
  const CollaboratorList({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final CollaboratorService collaboratorService = CollaboratorService();

    return StreamBuilder<List<Collaborator>>(
      stream: collaboratorService.getCollaboratorsForEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final collaborators = snapshot.data ?? [];

        return Card(
          child: Column(
            children: [
              ...collaborators.map(
                (collaborator) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(collaborator.email),
                  subtitle: Text(collaborator.role),
                  onLongPress: () async {
                    // Option to delete collaborator
                    await collaboratorService.deleteCollaborator(
                      collaborator.id,
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Collaborator'),
                onTap: () {
                  _showAddCollaboratorDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCollaboratorDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Collaborator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Collaborator Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // NOTE: In a real app, you would validate the email and check if the user exists in Firebase Auth
                final newCollaborator = Collaborator(
                  id: '', // ID will be generated by Firestore
                  eventId: eventId,
                  userId: '', // Will be determined from email in a real app
                  email: emailController.text,
                  role: roleController.text,
                );
                await CollaboratorService().addCollaborator(newCollaborator);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
