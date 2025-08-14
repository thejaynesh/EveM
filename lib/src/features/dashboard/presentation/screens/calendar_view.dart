import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../event_management/data/event_service.dart';
import '../../../../shared/models/event.dart';
import 'package:go_router/go_router.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final EventService _eventService = EventService();
  List<Event> _events = [];
  List<Event> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  void _fetchEvents() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _eventService.getEventsForManager(currentUser.uid).listen((events) {
        setState(() {
          _events = events;
          _selectedEvents = _getEventsForDay(_selectedDay!); // Update selected events on data change
        });
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) =>
        event.date.year == day.year &&
        event.date.month == day.month &&
        event.date.day == day.day
    ).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getEventsForDay,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: _buildEventsMarker(date, events.cast<Event>()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedEvents.length,
            itemBuilder: (context, index) {
              final event = _selectedEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(event.time.format(context)),
                  onTap: () {
                    context.go('/event-details/${event.id}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventsMarker(DateTime date, List<Event> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.secondary,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
    );
  }
}
