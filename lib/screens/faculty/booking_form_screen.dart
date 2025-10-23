import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class BookingFormScreen extends StatefulWidget {
  final SeminarHall hall;
  final DateTime date;
  final TimeOfDay startTime;
  final int duration;

  const BookingFormScreen({
    super.key,
    required this.hall,
    required this.date,
    required this.startTime,
    required this.duration,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _purposeController = TextEditingController(); // <-- ADDED
  final _attendeesController = TextEditingController();
  final _requirementsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final appState = context.read<AppState>();
      final currentUser = appState.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Not logged in.')));
        setState(() => _isLoading = false);
        return;
      }
      
      final startDateTime = DateTime(widget.date.year, widget.date.month, widget.date.day, widget.startTime.hour, widget.startTime.minute);
      final endDateTime = startDateTime.add(Duration(hours: widget.duration));

      final newBooking = Booking(
        id: '',
        title: _titleController.text.trim(),
        purpose: _purposeController.text.trim(), // <-- ADDED
        hall: widget.hall.name,
        date: DateFormat('yyyy-MM-dd').format(widget.date),
        startTime: DateFormat('HH:mm').format(startDateTime),
        endTime: DateFormat('HH:mm').format(endDateTime),
        status: 'Pending',
        requestedBy: currentUser.name,
        requesterId: currentUser.uid,
        department: currentUser.department,
        expectedAttendees: int.parse(_attendeesController.text),
        additionalRequirements: _requirementsController.text.trim(),
        rejectionReason: null,
      );

      await appState.submitBooking(newBooking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking request has been submitted successfully!')));
        context.go('/my-bookings');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'This field is required' : null),
              const SizedBox(height: 16),
              // ✅ FIX: Added the TextFormField for Purpose
              TextFormField(controller: _purposeController, decoration: const InputDecoration(labelText: 'Purpose of Event', border: OutlineInputBorder()), maxLines: 3, validator: (v) => v!.isEmpty ? 'This field is required' : null),
              const SizedBox(height: 16),
              TextFormField(
                controller: _attendeesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Expected Attendees (Max: ${widget.hall.capacity})', border: const OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'This field is required';
                  final count = int.tryParse(v);
                  if (count == null) return 'Please enter a valid number';
                  if (count <= 0) return 'Attendees must be greater than zero';
                  if (count > widget.hall.capacity) return 'Number of attendees exceeds hall capacity';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _requirementsController, decoration: const InputDecoration(labelText: 'Additional Requirements (Optional)', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Request'),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSummaryCard() {
    final formattedDate = DateFormat.yMMMMd().format(widget.date);
    final formattedTime = widget.startTime.format(context);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow(icon: Icons.business_outlined, text: widget.hall.name),
            const SizedBox(height: 8),
            _buildSummaryRow(icon: Icons.calendar_today_outlined, text: formattedDate),
            const SizedBox(height: 8),
            _buildSummaryRow(icon: Icons.access_time_outlined, text: 'Starting at $formattedTime for ${widget.duration} hour(s)'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }
}