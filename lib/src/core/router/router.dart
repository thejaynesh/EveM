import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/manager_login_screen.dart';
import '../../features/dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/profile_page.dart';
import '../../features/dashboard/presentation/screens/settings_screen.dart';
import '../../features/event_management/presentation/screens/add_event_screen.dart';
import '../../features/event_management/presentation/screens/budget_management_screen.dart';
import '../../features/event_management/presentation/screens/event_details_screen.dart';
import '../../features/event_management/presentation/screens/edit_event_screen.dart';
import '../../features/dashboard/presentation/screens/edit_profile_screen.dart';
import '../../features/attendee/presentation/screens/attendee_login_screen.dart';
import '../../features/attendee/presentation/screens/attendee_register_screen.dart';
import '../../features/attendee/presentation/screens/attendee_dashboard_screen.dart';
import '../../features/attendee/presentation/screens/attendee_event_details_screen.dart';
import '../../features/attendee/presentation/screens/event_discovery_screen.dart';
import '../../features/attendee/presentation/screens/my_tickets_screen.dart';
import '../../features/attendee/presentation/screens/notifications_screen.dart';
import '../../features/attendee/presentation/screens/attendee_profile_screen.dart';
import '../../../src/shared/widgets/manager_scaffold.dart';
import '../../../src/shared/widgets/attendee_scaffold.dart';
import '../../../src/shared/widgets/public_scaffold.dart';


class AppRouter {

  static final GoRouter router = GoRouter(
    initialLocation: '/discover',
    redirect: (BuildContext context, GoRouterState state) async {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      final String location = state.uri.toString();

      // Define public routes that do not require authentication
      final isPublicRoute = location.startsWith('/discover') ||
          location == '/manager-login' ||
          location == '/attendee/login' ||
          location == '/attendee/register';

      // If the user is not logged in and not on a public route, redirect to the discovery page
      if (!loggedIn && !isPublicRoute) {
        return '/discover';
      }

      if (loggedIn) {
      
        // Allow logged-in users to access login pages to switch accounts.
        if (location == '/manager-login' || location == '/attendee/login' || location == '/attendee/register') {
          return null;
        }
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/discover',
      ),
      // Public routes with a public scaffold
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return PublicScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/discover',
            builder: (BuildContext context, GoRouterState state) =>
                const EventDiscoveryScreen(),
          ),
          GoRoute(
            path: '/attendee/login',
            builder: (BuildContext context, GoRouterState state) =>
                const AttendeeLoginScreen(),
          ),
          GoRoute(
            path: '/attendee/register',
            builder: (BuildContext context, GoRouterState state) =>
                const AttendeeRegisterScreen(),
          ),
          GoRoute(
            path: '/manager-login',
            builder: (BuildContext context, GoRouterState state) =>
                const ManagerLoginScreen(),
          ),
        ],
      ),

      // Manager routes with a scaffold
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ManagerScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/manager/dashboard',
            builder: (BuildContext context, GoRouterState state) =>
                const ManagerDashboardScreen(),
          ),
          GoRoute(
            path: '/manager/add-event',
            builder: (BuildContext context, GoRouterState state) =>
                const AddEventScreen(),
          ),
          GoRoute(
            path: '/manager/profile-page',
            builder: (BuildContext context, GoRouterState state) =>
                const ProfilePage(),
          ),
          GoRoute(
            path: '/manager/profile',
            builder: (BuildContext context, GoRouterState state) =>
                const EditProfileScreen(),
          ),
          GoRoute(
            path: '/manager/settings',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsScreen(),
          ),
          GoRoute(
            path: '/manager/event-details/:eventId',
            builder: (BuildContext context, GoRouterState state) {
              final String eventId = state.pathParameters['eventId']!;
              return EventDetailsScreen(eventId: eventId);
            },
          ),
          GoRoute(
            path: '/manager/edit-event/:eventId',
            builder: (BuildContext context, GoRouterState state) {
              final String eventId = state.pathParameters['eventId']!;
              return EditEventScreen(eventId: eventId);
            },
          ),
          GoRoute(
            path: '/manager/budget/:eventId',
            builder: (BuildContext context, GoRouterState state) {
              final eventId = state.pathParameters['eventId']!;
              return BudgetManagementScreen(eventId: eventId);
            },
          ),
        ],
      ),

      // Attendee routes with a scaffold
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AttendeeScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/attendee/dashboard',
            builder: (BuildContext context, GoRouterState state) =>
                const AttendeeDashboardScreen(),
          ),
          GoRoute(
            path: '/attendee/tickets',
            builder: (BuildContext context, GoRouterState state) =>
                const MyTicketsScreen(),
          ),
          GoRoute(
            path: '/attendee/notifications',
            builder: (BuildContext context, GoRouterState state) =>
                const NotificationsScreen(),
          ),
          GoRoute(
            path: '/attendee/profile',
            builder: (BuildContext context, GoRouterState state) =>
                const AttendeeProfileScreen(),
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
       GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
    ],
  );
}
