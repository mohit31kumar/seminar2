import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:intl/intl.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Security check
    if (appState.currentUser?.role != 'admin') {
      return const Scaffold(body: Center(child: Text('Access Denied.')));
    }

    final pendingBookings = appState.bookings.where((b) => b.status == 'Pending').toList();
    // Sort to show the newest requests first
    pendingBookings.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
        centerTitle: false,
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingBookings.isEmpty
              ? const Center(
                  child: Text(
                    'No pending requests.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: pendingBookings.length,
                  itemBuilder: (context, index) {
                    final booking = pendingBookings[index];
                    final formattedDate = DateFormat.yMMMd().format(DateTime.parse(booking.date));
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        title: Text(
                          booking.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'By: ${booking.requestedBy}\n'
                          'For: ${booking.hall}\n'
                          'On: $formattedDate (${booking.startTime} - ${booking.endTime})',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                           context.go('/admin/review', extra: booking);
                          // This screen would allow the admin to Approve, Reject, or Re-allocate.
                          // e.g., context.go('/admin/review', extra: booking);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review screen not yet implemented.')),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}