import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:seminar_booking_app/services/auth_service.dart';
import 'package:seminar_booking_app/widgets/admin/add_user_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              // Use read() here as we are in a callback
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

    // --- FIX: Get the UID to compare for the 'self' check ---
    final currentAdminUid = currentUser.uid;

    // 1. Filter all users based on search query
    final filteredUsers = appState.allUsers.where((user) {
      // --- FIX: REMOVED the line that excluded the current user ---
      // if (user.uid == currentAdminUid) return false; // <-- This was the bug

      // If search is empty, show all. Otherwise, filter.
      if (_searchQuery.isEmpty) return true;

      final nameMatch = user.name.toLowerCase().contains(_searchQuery);
      final emailMatch = user.email.toLowerCase().contains(_searchQuery);
      return nameMatch || emailMatch;
    }).toList();

    // --- FIX: Correctly separate users into two lists ---
    final adminUsers =
    filteredUsers.where((user) => user.role == 'admin').toList();
    final facultyUsers =
    filteredUsers.where((user) => user.role == 'Faculty').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        // No centerTitle, 'leading' back button will be added by AppShell
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
      body: Column(
        children: [
          // --- 1. SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
              ),
            ),
          ),

          // --- 2. USER LISTS ---
          Expanded(
            child: (adminUsers.isEmpty && facultyUsers.isEmpty)
                ? const Center(
              child: Text(
                'No users found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                // --- Admin Section ---
                _buildSectionTitle(context, 'Admins'),
                if (adminUsers.isEmpty && _searchQuery.isNotEmpty)
                  _buildEmptySection('No admins match your search.')
                else if (adminUsers.isEmpty)
                  _buildEmptySection('No admins found.')
                else
                  ...adminUsers.map((user) =>
                  // --- FIX: Pass currentAdminUid ---
                  _buildUserCard(context, user, currentAdminUid))
                      ,

                // --- Faculty Section ---
                _buildSectionTitle(context, 'Faculty'),
                if (facultyUsers.isEmpty && _searchQuery.isNotEmpty)
                  _buildEmptySection('No faculty match your search.')
                else if (facultyUsers.isEmpty)
                  _buildEmptySection('No faculty found.')
                else
                  ...facultyUsers.map((user) =>
                  // --- FIX: Pass currentAdminUid ---
                  _buildUserCard(context, user, currentAdminUid))
                      ,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget for the user list item
  // --- FIX: Added currentAdminUid parameter ---
  Widget _buildUserCard(BuildContext context, User user, String currentAdminUid) {
    // --- FIX: Check if the card being built is for the current admin ---
    final bool isSelf = user.uid == currentAdminUid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
        ),
        title: Text(
          user.name + (isSelf ? ' (You)' : ''), // Add '(You)' label
          style: TextStyle(
            fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(user.email),
        // --- FIX: Disable the menu for the current admin's own card ---
        trailing: isSelf
            ? null // No menu for self
            : PopupMenuButton<String>(
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
  }

  /// Helper widget for section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Helper widget for empty sections
  Widget _buildEmptySection(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}