import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class FacultyHomeScreen extends StatelessWidget {
  const FacultyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final theme = Theme.of(context);

    // This screen should not be accessible without a logged-in user.
    // The router's redirect handles this, but this is a fallback.
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final myBookings = appState.bookings.where((b) => b.requesterId == currentUser.uid).toList();
    final pendingCount = myBookings.where((b) => b.status == 'Pending').length;
    final approvedCount = myBookings.where((b) => b.status == 'Approved').length;
    final rejectedCount = myBookings.where((b) => b.status == 'Rejected').length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${currentUser.name.split(' ').first}'),
        centerTitle: false,
        actions: [
          // A quick-access button to the user's profile
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Profile',
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Primary action button
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create New Booking'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.go('/booking'),
            ),
            const SizedBox(height: 24),

            // Summary section
            Text('My Requests Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(context, 'Pending', pendingCount, Colors.orange.shade700),
                    _buildStatChip(context, 'Approved', approvedCount, Colors.green.shade700),
                    _buildStatChip(context, 'Rejected', rejectedCount, Colors.red.shade700),
                  ],
                ),
              ),
            ),
            // TODO: Add sections for "Upcoming Events" and "Recent Activity" here
            // using the 'myBookings' list.
          ],
        ),
      ),
    );
  }
  
  // Helper widget for the summary chips
  Widget _buildStatChip(BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Text(
            count.toString(),
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}