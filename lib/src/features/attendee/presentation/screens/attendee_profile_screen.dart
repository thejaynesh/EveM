import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendeeProfileScreen extends StatefulWidget {
  const AttendeeProfileScreen({super.key});

  @override
  AttendeeProfileScreenState createState() => AttendeeProfileScreenState();
}

class AttendeeProfileScreenState extends State<AttendeeProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: currentUser?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ), // Max width for content
          child: Card(
            elevation: Theme.of(
              context,
            ).cardTheme.elevation, // Use theme elevation
            shape: Theme.of(context).cardTheme.shape, // Use theme shape
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Stretch children horizontally
                  children: [
                    Text(
                      'My Profile',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person),
                      ), // Styling handled by InputDecorationTheme
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      cursorColor: colorScheme.primary,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (currentUser != null) {
                            await currentUser!.updateDisplayName(
                              _nameController.text,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Profile Updated!',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                                backgroundColor: colorScheme.primary,
                              ),
                            );
                            if (!context.mounted) return;
                            // No pop here, as it's a profile screen; remain on screen after update
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'User not logged in.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onError,
                                  ),
                                ),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
