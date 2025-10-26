// lib/screens/shared/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  // ... (rest of StatefulWidget code)
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  // ... (all existing code: _isEditing, _formKey, controllers, etc.)
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _departmentController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = context.read<AppState>().currentUser;
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _departmentController =
        TextEditingController(text: currentUser?.department ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      final appState = context.read<AppState>();
      try {
        await appState.updateUserProfile(
          name: _nameController.text.trim(),
          department: _departmentController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green),
          );
          setState(() => _isEditing = false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error updating profile: $e'),
                backgroundColor: Colors.red),
          );
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
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save Changes',
              onPressed: _handleSaveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FORM FOR EDITABLE FIELDS ---
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _departmentController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business_center_outlined),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Department cannot be empty' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- READ-ONLY FIELDS ---
            TextFormField(
              initialValue: currentUser.email,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email Address (Read-Only)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: currentUser.employeeId,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Employee ID (Read-Only)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: OutlinedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    _nameController.text = currentUser.name;
                    _departmentController.text = currentUser.department;
                    setState(() => _isEditing = false);
                  },
                ),
              ),

            // --- DIVIDER ---
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(),
            ),

            // --- ✅ NEW: ABOUT TEAM BUTTON ---
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('About Team Shunya'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Use push for better back navigation
                context.push('/about-us');
              },
            ),
            const SizedBox(height: 16), // Add some space before logout
            // --- END NEW ---

            // --- LOGOUT BUTTON ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 16)),
              onPressed: () {
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
      ),
    );
  }
}