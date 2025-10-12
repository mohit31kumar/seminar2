import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:seminar_booking_app/services/auth_service.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  /// Shows a confirmation dialog and triggers the password reset email.
  void _sendPasswordReset(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Password Reset'),
        content: Text('Are you sure you want to send a password reset link to ${user.email}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Send Link'),
            onPressed: () async {
              final authService = context.read<AuthService>();
              final error = await authService.sendPasswordResetEmail(user.email);
              Navigator.of(dialogContext).pop(); // Close the dialog
              
              // Show a snackbar with the result
              final snackBar = SnackBar(
                content: Text(error == null ? 'Password reset email sent to ${user.email}.' : 'Error: $error'),
                backgroundColor: error == null ? Colors.green : Colors.red,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    // Security check: only admins can view this screen.
    if (appState.currentUser?.role != 'admin') {
      return const Scaffold(
        body: Center(child: Text('Access Denied: You do not have permission to view this page.')),
      );
    }
    
    final allUsers = appState.allUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: allUsers.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.builder(
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text('${user.email}\nRole: ${user.role}'),
                    isThreeLine: true,
                    trailing: user.role != 'admin' ? 
                      // Using a PopupMenuButton for future actions like 'Delete' or 'Edit Role'
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'reset_password') {
                            _sendPasswordReset(context, user);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'reset_password',
                            child: Text('Send Password Reset'),
                          ),
                          // You can add more admin actions here in the future
                        ],
                      ) 
                      : null, // No actions for admins to prevent self-lockout
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement a dialog or screen for the admin to add a new user manually.
        },
        tooltip: 'Add New User',
        child: const Icon(Icons.add),
      ),
    );
  }
}