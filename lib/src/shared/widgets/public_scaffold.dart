import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicScaffold extends StatefulWidget {
  final Widget child;

  const PublicScaffold({
    super.key,
    required this.child,
  });

  @override
  State<PublicScaffold> createState() => _PublicScaffoldState();
}

class _PublicScaffoldState extends State<PublicScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/attendee-login')) {
      return 1;
    }
    if (location.startsWith('/attendee-register')) {
      return 2;
    }
    if (location.startsWith('/manager-login')) {
      return 3;
    }
    // Default to Explore Events
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/explore-events');
        break;
      case 1:
        context.go('/attendee-login');
        break;
      case 2:
        context.go('/attendee-register');
        break;
      case 3:
        context.go('/manager-login');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EveM'),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: Text('Explore Events'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.login_outlined),
                selectedIcon: Icon(Icons.login),
                label: Text('Attendee Login'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_add_outlined),
                selectedIcon: Icon(Icons.person_add),
                label: Text('Attendee Register'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_center_outlined),
                selectedIcon: Icon(Icons.business_center),
                label: Text('Manager Login'),
              ),
            ],
            extended: true,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
