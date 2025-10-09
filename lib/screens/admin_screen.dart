import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/stat_card.dart'; 

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.currentUser?.role != 'admin') {
      return const Center(child: Text('Access Denied.'));
    }

    final allBookings = appState.allBookings;
    final pendingCount = allBookings.where((b) => b.status == 'pending').length;
    final bookedCount = allBookings.where((b) => b.status == 'booked').length;
    final userCount = appState.users.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.0,
            children: [
              StatCard(icon: Icons.event_note, title: 'Total Bookings', value: allBookings.length.toString()),
              StatCard(icon: Icons.hourglass_top, title: 'Pending', value: pendingCount.toString()),
              StatCard(icon: Icons.event_available, title: 'Booked', value: bookedCount.toString()),
              StatCard(icon: Icons.group, title: 'Total Users', value: userCount.toString()),
            ],
          ),
          const SizedBox(height: 24),
          const Center(child: Text('Booking requests list placeholder.')),
        ],
      ),
    );
  }
}