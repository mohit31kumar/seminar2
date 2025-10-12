import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Widget _getStatusChip(String status) {
    Color chipColor;
    String chipText = status;

    switch (status) {
      case 'Approved':
        chipColor = Colors.green;
        break;
      case 'Pending':
        chipColor = Colors.orange;
        break;
      case 'Rejected':
        chipColor = Colors.red;
        break;
      case 'Cancelled':
        chipColor = Colors.grey[600]!;
        break;
      default:
        chipColor = Colors.black;
        chipText = 'Unknown';
    }
    return Chip(
      label: Text(chipText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking request? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No, Keep It'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
              onPressed: () {
                // ✅ FIX: This call is now valid because the method exists in AppState.
                context.read<AppState>().cancelBooking(booking.id);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking has been cancelled.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Please log in to view your bookings.'));
    }

    final myBookings = appState.bookings.where((b) => b.requesterId == currentUser.uid).toList();
    myBookings.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking Requests'),
        centerTitle: false,
      ),
      body: myBookings.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "You haven't made any booking requests yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: myBookings.length,
              itemBuilder: (context, index) {
                final booking = myBookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(booking.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${booking.hall}\nOn: ${booking.date}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getStatusChip(booking.status),
                          if (booking.status == 'Pending' || booking.status == 'Approved')
                            IconButton(
                              icon: const Icon(Icons.cancel_outlined),
                              color: Colors.red.shade400,
                              tooltip: 'Cancel Booking',
                              onPressed: () => _showCancelConfirmationDialog(context, booking),
                            ),
                        ],
                      ),
                      onTap: () {
                        // TODO: Navigate to a detailed view of the booking
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}