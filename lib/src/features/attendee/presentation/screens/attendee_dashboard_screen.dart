import 'package:flutter/material.dart';
import 'event_discovery_screen.dart';
import 'notifications_screen.dart';
import 'my_tickets_screen.dart';

class AttendeeDashboardScreen extends StatefulWidget {
  const AttendeeDashboardScreen({super.key});

  @override
  State<AttendeeDashboardScreen> createState() =>
      _AttendeeDashboardScreenState();
}

class _AttendeeDashboardScreenState extends State<AttendeeDashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    EventDiscoveryScreen(),
    NotificationsScreen(),
    MyTicketsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendee Dashboard'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Discovery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'My Tickets',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
    );
  }
}
