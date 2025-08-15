import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/auth/data/auth_service.dart';

class AttendeeScaffold extends StatelessWidget {
  final Widget child;

  const AttendeeScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/attendee/notifications')) {
      return 1;
    } else if (location.startsWith('/attendee/tickets')) {
      return 2;
    } else if (location.startsWith('/attendee/profile')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendee Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/attendee/dashboard');
                  break;
                case 1:
                  context.go('/attendee/notifications');
                  break;
                case 2:
                  context.go('/attendee/tickets');
                  break;
                case 3:
                  context.go('/attendee/profile');
                  break;
              }
            },
            labelType: NavigationRailLabelType.none,
            extended: true,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: Text('Event Discovery'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: Text('My Tickets'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        context.go('/explore-events');
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
