import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/models/booking.dart';
// ignore: unused_import
import 'package:collection/collection.dart';

class AvailabilityCheckerScreen extends StatefulWidget {
  final SeminarHall hall;
  const AvailabilityCheckerScreen({super.key, required this.hall});

  @override
  State<AvailabilityCheckerScreen> createState() => _AvailabilityCheckerScreenState();
}

class _AvailabilityCheckerScreenState extends State<AvailabilityCheckerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeOfDay? _selectedStartTime;
  int _selectedDuration = 1; // Default duration is 1 hour

  /// Gets a list of bookings for a specific day and hall.
  List<Booking> _getEventsForDay(DateTime day, List<Booking> allBookings) {
    return allBookings
        .where((booking) =>
            booking.hall == widget.hall.name &&
            isSameDay(DateTime.parse(booking.date), day) &&
            (booking.status == 'Approved' || booking.status == 'Pending'))
        .toList();
  }

  /// Checks if the selected time slot is valid and does not conflict.
  bool _isTimeSlotValid(List<Booking> todaysBookings) {
    if (_selectedDay == null || _selectedStartTime == null) return false;

    final proposedStart = _selectedDay!.add(Duration(hours: _selectedStartTime!.hour, minutes: _selectedStartTime!.minute));
    final proposedEnd = proposedStart.add(Duration(hours: _selectedDuration));

    for (final booking in todaysBookings) {
      final existingStart = DateTime.parse(booking.date).add(Duration(hours: int.parse(booking.startTime.split(':')[0])));
      final existingEnd = DateTime.parse(booking.date).add(Duration(hours: int.parse(booking.endTime.split(':')[0])));
      
      // Check for overlap
      if (proposedStart.isBefore(existingEnd) && proposedEnd.isAfter(existingStart)) {
        return false; // Conflict found
      }
    }
    return true; // No conflicts
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = context.watch<AppState>().bookings;
    final todaysBookings = _selectedDay != null ? _getEventsForDay(_selectedDay!, allBookings) : <Booking>[];
    final isSlotValid = _isTimeSlotValid(todaysBookings);

    return Scaffold(
      appBar: AppBar(title: Text('Select Date for ${widget.hall.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calendar View
            Card(
              child: TableCalendar<Booking>(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedStartTime = null; // Reset time when day changes
                  });
                },
                eventLoader: (day) => _getEventsForDay(day, allBookings),
              ),
            ),
            const SizedBox(height: 24),

            // Time Slot Selection (only appears after selecting a day)
            if (_selectedDay != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text('Select Start Time & Duration', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedStartTime?.format(context) ?? 'Choose Start Time'),
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context, 
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (time != null) setState(() => _selectedStartTime = time);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedDuration,
                      items: [1, 2, 3, 4, 5, 6, 7, 8].map((h) => DropdownMenuItem(value: h, child: Text('$h Hour(s)'))).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedDuration = value);
                      },
                      decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              // Validation message
              if (_selectedStartTime != null && !isSlotValid)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'This time slot conflicts with an existing booking. Please choose a different time or duration.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ],
        ),
      ),
      // Proceed button is enabled only when a valid time slot is selected
      floatingActionButton: (_selectedDay != null && _selectedStartTime != null && isSlotValid)
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to the final booking form, passing all data as 'extra'
                context.go('/booking/form', extra: {
                  'hall': widget.hall,
                  'date': _selectedDay!,
                  'startTime': _selectedStartTime!,
                  'duration': _selectedDuration,
                });
              },
              label: const Text('Proceed'),
              icon: const Icon(Icons.arrow_forward),
            )
          : null,
    );
  }
}