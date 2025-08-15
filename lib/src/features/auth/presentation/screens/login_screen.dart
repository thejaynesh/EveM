import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Keep if specific GoogleFonts are still needed
import '../../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
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
              colorScheme.primary.withAlpha(
                (255 * 0.8).round(),
              ), // Start with a slightly faded primary
              colorScheme.secondary, // End with the secondary color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ), // Max width for larger screens
              child: Card(
                elevation: Theme.of(context).cardTheme.elevation,
                shape: Theme.of(context).cardTheme.shape,
                margin: EdgeInsets.zero, // Remove default card margin
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Wrap content
                      children: [
                        Text(
                          'EveM',
                          style: GoogleFonts.poppins(
                            fontSize:
                                54, // Slightly smaller than displayLarge for direct use
                            fontWeight: FontWeight.bold,
                            color: colorScheme
                                .primary, // Use primary color for app title
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome Back, Manager!',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme
                                .onSurface, // Use onSurface for text within card
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
                                  .signInWithEmailAndPassword(email, password);
                              if (!context.mounted) return;
                              if (result == null) {
                                setState(
                                  () => error =
                                      'Could not sign in with those credentials',
                                );
                              } else {
                                context.go('/manager/dashboard');
                              }
                            }
                          },
                          // Styling is now handled by ElevatedButtonThemeData in AppTheme
                          child: const Text('Login'),
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
                            context.go('/register');
                          },
                          child: Text(
                            'Don\'t have an account? Register',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme
                                  .primary, // Use primary color for link
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
    // InputDecoration styling is now largely handled by InputDecorationTheme in AppTheme
    return TextFormField(
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: InputDecoration(
        labelText: label,
        // labelStyle and hintStyle are now handled by InputDecorationTheme
      ),
      validator: (val) => val!.isEmpty ? 'Enter an email' : null,
      onChanged: onChanged,
    );
  }
}
