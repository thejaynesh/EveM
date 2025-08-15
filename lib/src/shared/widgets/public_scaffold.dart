import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicScaffold extends StatefulWidget {
  final Widget child;

  const PublicScaffold({super.key, required this.child});

  @override
  State<PublicScaffold> createState() => _PublicScaffoldState();
}

class _PublicScaffoldState extends State<PublicScaffold> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/discover')) {
      return 0;
    }
    if (location.startsWith('/attendee/login')) {
      return 1;
    }
    if (location.startsWith('/attendee/register')) {
      return 2;
    }
    if (location.startsWith('/manager-login')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/discover');
        break;
      case 1:
        context.go('/attendee/login');
        break;
      case 2:
        context.go('/attendee/register');
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
        title: const Text('Event Discovery'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Row(
        children: [
          LayoutBuilder(
            builder: (context, constraint) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: _calculateSelectedIndex(context),
                      onDestinationSelected: (index) => _onItemTapped(index, context),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.explore_outlined),
                          selectedIcon: Icon(Icons.explore),
                          label: Text('Discover'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.login_outlined),
                          selectedIcon: Icon(Icons.login),
                          label: Text('Login'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person_add_alt_1_outlined),
                          selectedIcon: Icon(Icons.person_add_alt_1),
                          label: Text('Register'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.admin_panel_settings_outlined),
                          selectedIcon: Icon(Icons.admin_panel_settings),
                          label: Text('Manager Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
