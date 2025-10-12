import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Widget _getStatusChip(String status) {
    Color color;
    switch (status) {
      case 'booked': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Chip(label: Text(status, style: const TextStyle(color: Colors.white)), backgroundColor: color);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in.'));
    }

    final myBookings = appState.bookings.where((b) => b.requesterId == currentUser.uid).toList();

    return myBookings.isEmpty
        ? const Center(child: Text('You have no booking requests.'))
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: myBookings.length,
            itemBuilder: (context, index) {
              final booking = myBookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(booking.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${booking.hall}\nOn: ${booking.date}'),
                  trailing: _getStatusChip(booking.status),
                ),
              );
            },
          );
  }
}