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
  final int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    EventDiscoveryScreen(),
    NotificationsScreen(),
    MyTicketsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      
    );
  }
}
