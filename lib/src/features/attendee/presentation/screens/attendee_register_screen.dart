import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/auth_service.dart';

class AttendeeRegisterScreen extends StatefulWidget {
  const AttendeeRegisterScreen({super.key});

  @override
  _AttendeeRegisterScreenState createState() => _AttendeeRegisterScreenState();
}

class _AttendeeRegisterScreenState extends State<AttendeeRegisterScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'EveM',
                    style: GoogleFonts.oswald(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Your Attendee Account',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildTextField(context, 'Email', onChanged: (val) {
                    setState(() => email = val);
                  }),
                  const SizedBox(height: 24),
                  _buildTextField(context, 'Password', obscureText: true, onChanged: (val) {
                    setState(() => password = val);
                  }),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                        if (result == null) {
                          setState(() => error = 'Please supply a valid email');
                        } else {
                          context.go('/attendee-dashboard');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    ),
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                  const SizedBox(height: 12.0),
                  TextButton(
                    onPressed: () {
                      context.go('/attendee-login');
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, {bool obscureText = false, required Function(String) onChanged}) {
    return TextFormField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      validator: (val) => val!.isEmpty ? 'Enter an email' : null,
      onChanged: onChanged,
    );
  }
}
