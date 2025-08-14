import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../features/event_management/presentation/screens/add_event_screen.dart';
import '../../features/event_management/presentation/screens/event_details_screen.dart';
import '../../features/event_management/presentation/screens/edit_event_screen.dart';
import '../../features/dashboard/presentation/screens/edit_profile_screen.dart';
import '../../features/attendee/presentation/screens/attendee_login_screen.dart';
import '../../features/attendee/presentation/screens/attendee_register_screen.dart';
import '../../features/attendee/presentation/screens/attendee_dashboard_screen.dart';
import '../../features/attendee/presentation/screens/attendee_event_details_screen.dart';
import '../../features/attendee/presentation/screens/attendee_profile_screen.dart';
import '../../shared/models/event.dart';
import '../../shared/widgets/manager_scaffold.dart';
import '../../shared/widgets/attendee_scaffold.dart';
import '../../shared/widgets/public_scaffold.dart';
import '../../features/attendee/presentation/screens/event_discovery_screen.dart';
import '../../features/attendee/presentation/screens/my_tickets_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/explore-events',
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return PublicScaffold(
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/explore-events',
          builder: (BuildContext context, GoRouterState state) => const EventDiscoveryScreen(),
        ),
        GoRoute(
          path: '/attendee-login',
          builder: (BuildContext context, GoRouterState state) => const AttendeeLoginScreen(),
        ),
        GoRoute(
          path: '/attendee-register',
          builder: (BuildContext context, GoRouterState state) => const AttendeeRegisterScreen(),
        ),
        GoRoute(
          path: '/manager-login',
          builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ManagerScaffold(
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/manager/dashboard',
          builder: (BuildContext context, GoRouterState state) => const ManagerDashboardScreen(),
        ),
        GoRoute(
          path: '/manager/add-event',
          builder: (BuildContext context, GoRouterState state) => const AddEventScreen(),
        ),
        GoRoute(
          path: '/manager/profile',
          builder: (BuildContext context, GoRouterState state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/manager/event-details/:eventId',
          builder: (BuildContext context, GoRouterState state) {
            final String eventId = state.pathParameters['eventId']!;
            return EventDetailsScreen(eventId: eventId);
          },
        ),
        GoRoute(
          path: '/manager/edit-event',
          builder: (BuildContext context, GoRouterState state) {
            final event = state.extra as Event;
            return EditEventScreen(event: event);
          },
        ),
      ],
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AttendeeScaffold(
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/attendee/dashboard',
          builder: (BuildContext context, GoRouterState state) => const AttendeeDashboardScreen(),
        ),
        GoRoute(
          path: '/attendee/profile',
          builder: (BuildContext context, GoRouterState state) => const AttendeeProfileScreen(),
        ),
        GoRoute(
          path: '/attendee/tickets',
          builder: (BuildContext context, GoRouterState state) => const MyTicketsScreen(),
        ),
        GoRoute(
          path: '/attendee/event-details/:eventId',
          builder: (BuildContext context, GoRouterState state) {
            final String eventId = state.pathParameters['eventId']!;
            return AttendeeEventDetailsScreen(eventId: eventId);
          },
        ),
      ],
    ),
  ],
);
