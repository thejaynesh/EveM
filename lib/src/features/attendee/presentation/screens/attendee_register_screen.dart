import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/auth_service.dart';

class AttendeeRegisterScreen extends StatefulWidget {
  const AttendeeRegisterScreen({super.key});

  @override
  AttendeeRegisterScreenState createState() => AttendeeRegisterScreenState();
}

class AttendeeRegisterScreenState extends State<AttendeeRegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withAlpha((255 * 0.8).round()),
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: Theme.of(context).cardTheme.elevation,
                shape: Theme.of(context).cardTheme.shape,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'EveM',
                          style: GoogleFonts.poppins(
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Create Your Attendee Account',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        _buildTextField(
                          context,
                          'Email',
                          onChanged: (val) {
                            setState(() => email = val);
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          context,
                          'Password',
                          obscureText: true,
                          onChanged: (val) {
                            setState(() => password = val);
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              dynamic result = await _auth
                                  .registerWithEmailAndPassword(
                                    email,
                                    password
                                  );
                              if (!context.mounted) return;
                              if (result == null) {
                                setState(
                                  () => error = 'Please supply a valid email',
                                );
                              } else {
                                context.go('/attendee/dashboard');
                              }
                            }
                          },
                          child: const Text('Register'),
                        ),
                        if (error.isNotEmpty) ...[
                          const SizedBox(height: 12.0),
                          Text(
                            error,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            context.go('/attendee-login');
                          },
                          child: Text(
                            'Don\'t have an account? Login',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label, {
    bool obscureText = false,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: InputDecoration(labelText: label),
      validator: (val) => val!.isEmpty ? 'Enter an email' : null,
      onChanged: onChanged,
    );
  }
}
