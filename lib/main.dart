import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/core/router/router.dart';
import 'src/features/attendee/data/registration_service.dart';
import 'src/features/auth/data/auth_service.dart';
import 'src/features/event_management/data/budget_service.dart';
import 'src/features/event_management/data/collaborator_service.dart';
import 'src/features/event_management/data/event_service.dart';
import 'src/features/event_management/data/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<EventService>(create: (_) => EventService()),
        Provider<TaskService>(create: (_) => TaskService()),
        Provider<CollaboratorService>(create: (_) => CollaboratorService()),
        Provider<BudgetService>(create: (_) => BudgetService()),
        Provider<RegistrationService>(create: (_) => RegistrationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Event Management App',
      routerConfig: AppRouter.router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
