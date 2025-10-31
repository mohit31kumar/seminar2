// lib/screens/shared/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _departmentController;
  late TextEditingController _employeeIdController; // ✅ ADDED
  
  bool _isNewUser = false; // To show the welcome message
  bool _isLoading = false; // For the save button

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = context.read<AppState>().currentUser;
    
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _departmentController =
        TextEditingController(text: currentUser?.department ?? '');
    _employeeIdController = 
        TextEditingController(text: currentUser?.employeeId ?? ''); // ✅ ADDED

    // Check for incomplete data
    if (currentUser?.department == 'Unknown' || currentUser?.employeeId == '0000') {
      _isNewUser = true; // Set flag to show a message
      // Clear the placeholder values so the user must enter new ones
      if (currentUser?.department == 'Unknown') _departmentController.clear();
      if (currentUser?.employeeId == '0000') _employeeIdController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _employeeIdController.dispose(); // ✅ ADDED
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final appState = context.read<AppState>();
      
      try {
        await appState.updateUserProfile(
          name: _nameController.text.trim(),
          department: _departmentController.text.trim(),
          employeeId: _employeeIdController.text.trim(), // ✅ PASS IT
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green),
          );
          // If they were a new user, they can now navigate away
          setState(() {
            _isNewUser = false;
          });
          // Optionally, navigate them home:
          // context.go('/'); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error updating profile: $e'),
                backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        // Automatically hide back button if it's a new user
        leading: _isNewUser ? const SizedBox() : null,
        actions: [
          IconButton(
            icon: Icon(appState.isDarkMode
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            tooltip: 'Toggle Theme',
            onPressed: () {
              context.read<AppState>().toggleTheme();
            },
          ),
        ],
      ),
      body: ListView( // Changed to ListView for better structure
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- User Header ---
          Center(
            child: CircleAvatar(
              radius: 50,
              // Try to get Google photo, otherwise placeholder
              backgroundImage: (currentUser.uid.isNotEmpty) // A simple check
                  ? null // TODO: Add Google profile pic URL if available
                  : null,
              child: (currentUser.uid.isEmpty) // TODO: Fix check
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentUser.name, // Name from Google
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser.email, // Email from Google
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // --- New User Message ---
          if (_isNewUser)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300)
              ),
              child: const Text(
                'Welcome! Please complete your profile to continue using the app.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          if (_isNewUser) const SizedBox(height: 20),

          // --- Form ---
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business_center_outlined),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Department cannot be empty' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _employeeIdController, // ✅ ADDED
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Employee ID cannot be empty' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSaveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                      )
                    : const Text('Save Profile'),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(),
          ),

          // --- Other Links ---
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('About TECH ŚŪNYA'), // ✅ UPDATED
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/about-us');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade700)),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text('Logout'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); 
                        context.read<AppState>().logout();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}