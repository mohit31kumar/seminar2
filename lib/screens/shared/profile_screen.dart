import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _departmentController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = context.read<AppState>().currentUser;
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _departmentController = TextEditingController(text: currentUser?.department ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _handleSaveChanges() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement update logic in AppState and FirestoreService
      // final appState = context.read<AppState>();
      // appState.updateUserProfile(
      //   name: _nameController.text,
      //   department: _departmentController.text,
      // );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile update functionality is not yet implemented.')),
      );
      
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Toggle between Edit and Save buttons
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
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
                validator: (v) => v!.isEmpty ? 'Department cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              // --- Read-Only Fields ---
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
              const SizedBox(height: 24),
              if (_isEditing)
                OutlinedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    // Reset form fields to original values
                    _nameController.text = currentUser.name;
                    _departmentController.text = currentUser.department;
                    setState(() => _isEditing = false);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}