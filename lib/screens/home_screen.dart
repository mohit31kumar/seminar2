import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAdmin = appState.currentUser?.role == 'admin';
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Poornima University Seminar Booking System', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Seamlessly book, manage, and organize your events.', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(isAdmin ? "/admin" : "/booking"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: Text(isAdmin ? "Go to Dashboard" : "Request a Hall"),
            ),
          ],
        ),
      ),
    );
  }
}