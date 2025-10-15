import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:seminar_booking_app/services/auth_service.dart';
import 'package:seminar_booking_app/widgets/admin/add_user_dialog.dart';


class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  /// Shows a confirmation dialog before deleting a user.
  void _showDeleteConfirmationDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to permanently delete the user ${user.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete User'),
            onPressed: () async {
              final authService = context.read<AuthService>();

              try {
                await authService.deleteUserByAdmin(uid: user.uid);

                if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User ${user.name} deleted successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  /// Sends a password reset email.
  void _sendPasswordReset(BuildContext context, User user) async {
    final authService = context.read<AuthService>();

    try {
      await authService.sendPasswordResetEmail(user.email);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to ${user.email}.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows a dialog to change a user's role.
  void _showChangeRoleDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedRole = user.role;

        return StatefulBuilder(
          builder: (stfContext, setState) {
            return AlertDialog(
              title: Text('Change Role for ${user.name}'),
              content: DropdownButton<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'Faculty', child: Text('Faculty')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    final appState = context.read<AppState>();

                    try {
                      // ✅ updateUserRole returns Future<void>, so just await it.
                      await appState.updateUserRole(user.uid, selectedRole);

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Role for ${user.name} updated to $selectedRole.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating role: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    if (currentUser == null || currentUser.role != 'admin') {
      return const Scaffold(
        body: Center(
          child: Text(
            'Access Denied.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    final currentAdminUid = currentUser.uid;

    final users = appState.allUsers
        .where((user) => user.uid != currentAdminUid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add New User',
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) => const AddUserDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: users.isEmpty
          ? const Center(
              child: Text(
                'No users found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child:
                          Text(user.name.isNotEmpty ? user.name[0] : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'reset_password':
                            _sendPasswordReset(context, user);
                            break;
                          case 'delete_user':
                            _showDeleteConfirmationDialog(context, user);
                            break;
                          case 'change_role':
                            _showChangeRoleDialog(context, user);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'reset_password',
                          child: Text('Send Password Reset'),
                        ),
                        PopupMenuItem(
                          value: 'change_role',
                          child: Text(
                            user.role == 'admin'
                                ? 'Demote to Faculty'
                                : 'Promote to Admin',
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete_user',
                          child: Text(
                            'Delete User',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
