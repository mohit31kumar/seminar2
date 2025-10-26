import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ... (all your existing variables _formKey, controllers, etc.)
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
  );


  Future<void> _performRegistration() async {
    // ... (your existing _performRegistration function)
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; _errorText = null; });

      final authService = context.read<AuthService>();
      final error = await authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        department: _departmentController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
      );

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please log in.')),
          );
          context.go('/login');
        } else {
          setState(() { _errorText = error; });
        }
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ WRAP WITH PopScope
    return PopScope(
      // This runs when the back button is pressed
      onPopInvoked: (didPop) {
        // didPop will be false because we are intercepting it
        if (!didPop) {
          // Manually navigate to the login screen
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                // ... (all your existing widgets for the form)
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Create Account", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Poornima Email ID', border: OutlineInputBorder()), validator: (v) => v!.isEmpty || !v.endsWith('@poornima.edu.in') ? 'Must be a valid Poornima email' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _employeeIdController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Employee ID', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 16),
                  TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true, validator: (v) => v == null || !_passwordRegExp.hasMatch(v) ? 'Password does not meet requirements' : null),
                  const SizedBox(height: 8),
                  const Text("Password must contain at least 8 characters, one uppercase, one lowercase, one number, and one symbol.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextFormField(controller: _confirmPasswordController, decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()), obscureText: true, validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
                  if (_errorText != null) ...[ const SizedBox(height: 16), Text(_errorText!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center), ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _performRegistration,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(onPressed: () => context.go('/login'), child: const Text("Already have an account? Login")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}