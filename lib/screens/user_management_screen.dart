import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.currentUser?.role != 'admin') {
      return const Center(child: Text('Access Denied.'));
    }
    final users = appState.allUsers;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* TODO: Add user dialog */ },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              leading: CircleAvatar(child: Text(user.name.isNotEmpty ? user.name[0] : '?')),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: user.role != 'admin' ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () { /* TODO: Delete user logic */ },
              ) : null,
            ),
          );
        },
      ),
    );
  }
}