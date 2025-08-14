import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
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

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'manager-login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginScreen();
          },
          routes: [
            GoRoute(
              path: 'register',
              builder: (BuildContext context, GoRouterState state) {
                return const RegisterScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: 'dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const ManagerDashboardScreen();
          },
        ),
        GoRoute(
          path: 'add-event',
          builder: (BuildContext context, GoRouterState state) {
            return const AddEventScreen();
          },
        ),
        GoRoute(
          path: 'event-details/:eventId',
          builder: (BuildContext context, GoRouterState state) {
            final eventId = state.pathParameters['eventId']!;
            return EventDetailsScreen(eventId: eventId);
          },
        ),
        GoRoute(
          path: 'edit-event',
          builder: (BuildContext context, GoRouterState state) {
            final event = state.extra as Event;
            return EditEventScreen(event: event);
          },
        ),
        GoRoute(
          path: 'edit-profile',
          builder: (BuildContext context, GoRouterState state) {
            return const EditProfileScreen();
          },
        ),
        GoRoute(
          path: 'attendee-login',
          builder: (BuildContext context, GoRouterState state) {
            return const AttendeeLoginScreen();
          },
          routes: [
            GoRoute(
              path: 'register',
              builder: (BuildContext context, GoRouterState state) {
                return const AttendeeRegisterScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: 'attendee-dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const AttendeeDashboardScreen();
          },
        ),
        GoRoute(
          path: 'attendee-event-details/:eventId',
          builder: (BuildContext context, GoRouterState state) {
            final eventId = state.pathParameters['eventId']!;
            return AttendeeEventDetailsScreen(eventId: eventId);
          },
        ),
        GoRoute(
          path: 'attendee-profile',
          builder: (BuildContext context, GoRouterState state) {
            return const AttendeeProfileScreen();
          },
        ),
      ],
    ),
  ],
);
