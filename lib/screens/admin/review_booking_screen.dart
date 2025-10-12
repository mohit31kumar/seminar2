import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:intl/intl.dart';

class ReviewBookingScreen extends StatelessWidget {
  final Booking booking;
  const ReviewBookingScreen({super.key, required this.booking});

  /// Shows a dialog forcing the admin to enter a rejection reason.
  void _showRejectionDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reason for Rejection'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g., Conflicting VIP event'),
            validator: (value) => value!.trim().isEmpty ? 'A reason is required' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<AppState>().reviewBooking(
                  bookingId: booking.id,
                  newStatus: 'Rejected',
                  rejectionReason: reasonController.text.trim(),
                );
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Go back from review screen
              }
            },
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }
  
  // TODO: Implement Re-allocation Dialog
  void _showReallocateDialog(BuildContext context) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Re-allocation feature not yet implemented.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(DateTime.parse(booking.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Review Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              'Event Details',
              [
                _buildDetailRow('Event Title', booking.title),
                // _buildDetailRow('Purpose', booking.purpose), // Removed as 'purpose' is not a field in Booking model
                _buildDetailRow('Attendees', booking.expectedAttendees.toString()),
                if (booking.additionalRequirements.isNotEmpty)
                  _buildDetailRow('Requirements', booking.additionalRequirements),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Schedule & Hall',
              [
                _buildDetailRow('Hall', booking.hall),
                _buildDetailRow('Date', formattedDate),
                _buildDetailRow('Time', '${booking.startTime} - ${booking.endTime}'),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'Requester Information',
              [
                _buildDetailRow('Name', booking.requestedBy),
                _buildDetailRow('Department', booking.department),
              ],
            ),
          ],
        ),
      ),
      // Action buttons at the bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                onPressed: () => _showRejectionDialog(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                   context.read<AppState>().reviewBooking(bookingId: booking.id, newStatus: 'Approved');
                   Navigator.pop(context); // Go back after approving
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}