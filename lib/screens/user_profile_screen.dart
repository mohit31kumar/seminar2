import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${currentUser.name}'),
          const SizedBox(height: 8),
          Text('Email: ${currentUser.email}'),
          const SizedBox(height: 8),
          Text('Department: ${currentUser.department}'),
          const SizedBox(height: 8),
          Text('Role: ${currentUser.role}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement profile editing logic
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}