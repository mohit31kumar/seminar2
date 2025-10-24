import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:collection/collection.dart';

class AvailabilityCheckerScreen extends StatefulWidget {
  final SeminarHall hall;
  const AvailabilityCheckerScreen({super.key, required this.hall});

  @override
  State<AvailabilityCheckerScreen> createState() =>
      _AvailabilityCheckerScreenState();
}

class _AvailabilityCheckerScreenState extends State<AvailabilityCheckerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // --- UPDATED ---
  // Store start and end TimeOfDay objects
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  final int _openingHour = 8; // 8:00 AM
  final int _closingHour = 18; // 6:00 PM (18:00)
  String? _validationError;

  /// Gets a list of bookings for a specific day and hall.
  List<Booking> _getEventsForDay(DateTime day, List<Booking> allBookings) {
    return allBookings
        .where((booking) =>
            booking.hall == widget.hall.name &&
            isSameDay(DateTime.parse(booking.date), day) &&
            (booking.status == 'Approved' || booking.status == 'Pending'))
        .toList();
  }

  /// Helper function to parse "HH:mm" strings into a Duration.
  Duration _parseTime(String time) {
    try {
      final parts = time.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return Duration(hours: hours, minutes: minutes);
    } catch (e) {
      return Duration.zero;
    }
  }

  // --- NEW ---
  /// Generates a list of hourly TimeOfDay objects for the Start Time dropdown.
  List<TimeOfDay> _generateStartTimeSlots() {
    List<TimeOfDay> slots = [];
    // Allows starting up to the hour *before* closing time
    for (int hour = _openingHour; hour < _closingHour; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

  // --- NEW ---
  /// Generates a list of hourly TimeOfDay objects for the End Time dropdown.
  List<TimeOfDay> _generateEndTimeSlots(TimeOfDay startTime) {
    List<TimeOfDay> slots = [];
    // Allows ending up to and *including* the closing time
    for (int hour = startTime.hour + 1; hour <= _closingHour; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

  // --- UPDATED ---
  /// Checks if the selected time range is valid and has no conflicts.
  bool _isSlotRangeValid() {
    if (_selectedDay == null || _selectedStartTime == null || _selectedEndTime == null) {
      setState(() => _validationError = 'Please select a start and end time.');
      return false;
    }
    
    final allBookings = context.read<AppState>().bookings;
    final todaysBookings = _getEventsForDay(_selectedDay!, allBookings);

    final proposedStart = _selectedDay!
        .add(Duration(hours: _selectedStartTime!.hour, minutes: _selectedStartTime!.minute));
    final proposedEnd = _selectedDay!
        .add(Duration(hours: _selectedEndTime!.hour, minutes: _selectedEndTime!.minute));

    // Check for conflicts
    for (final booking in todaysBookings) {
      final existingStart =
          DateTime.parse(booking.date).add(_parseTime(booking.startTime));
      final existingEnd =
          DateTime.parse(booking.date).add(_parseTime(booking.endTime));

      if (proposedStart.isBefore(existingEnd) &&
          proposedEnd.isAfter(existingStart)) {
        setState(() => _validationError = 'This time range conflicts with an existing booking.');
        return false; // Conflict found
      }
    }
    
    setState(() => _validationError = null);
    return true; // No conflicts
  }

  // --- NEW ---
  /// Formats the time for the dropdown labels, e.g., "11:00"
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  // --- NEW ---
  /// Formats the end time label as shown in your screenshot, e.g., "10:00 - 11:00"
  String _formatEndTimeLabel(TimeOfDay time) {
    final endHour = time.hour.toString().padLeft(2, '0');
    final startHour = (time.hour - 1).toString().padLeft(2, '0');
    return '$startHour:00 - $endHour:00';
  }

  void _onConfirmAndRequest() {
    if (_isSlotRangeValid()) {
      // Proceed to the booking form
      context.go('/booking/form', extra: {
        'hall': widget.hall,
        'date': _selectedDay!,
        'startTime': _selectedStartTime!,
        'endTime': _selectedEndTime!, // Pass End Time
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final allBookings = context.watch<AppState>().bookings;

    // Generate time slots for the dropdowns
    final startTimeSlots = _generateStartTimeSlots();
    final endTimeSlots = _selectedStartTime != null 
                         ? _generateEndTimeSlots(_selectedStartTime!) 
                         : <TimeOfDay>[];

    return Scaffold(
      appBar: AppBar(title: Text('Select Date for ${widget.hall.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CALENDAR VIEW ---
            Text('1. Select a Date', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: TableCalendar<Booking>(
                firstDay: DateTime.now().subtract(const Duration(days: 1)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (selectedDay.isBefore(DateUtils.dateOnly(DateTime.now()))) {
                    return;
                  }
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    // Reset times when day changes
                    _selectedStartTime = null; 
                    _selectedEndTime = null;
                    _validationError = null;
                  });
                },
                enabledDayPredicate: (day) {
                  return !day.isBefore(DateUtils.dateOnly(DateTime.now()));
                },
                eventLoader: (day) => _getEventsForDay(day, allBookings),
              ),
            ),
            const SizedBox(height: 24),

            // --- TIME SELECTION ---
            // This section only appears after a day is selected
            if (_selectedDay != null) ...[
              Text('2. Select a Time Range', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              
              // --- START TIME DROPDOWN ---
              DropdownButtonFormField<TimeOfDay>(
                initialValue: _selectedStartTime,
                hint: const Text('Select start time'),
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                ),
                items: startTimeSlots.map((time) {
                  return DropdownMenuItem<TimeOfDay>(
                    value: time,
                    child: Text(_formatTime(time)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStartTime = value;
                    // Reset end time and error if start time changes
                    _selectedEndTime = null;
                    _validationError = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- END TIME DROPDOWN ---
              DropdownButtonFormField<TimeOfDay>(
                initialValue: _selectedEndTime,
                hint: const Text('Select end time'),
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                ),
                // Disable dropdown if start time isn't selected
                disabledHint: _selectedStartTime == null ? const Text('Select a start time first') : null,
                items: _selectedStartTime == null ? [] : endTimeSlots.map((time) {
                  return DropdownMenuItem<TimeOfDay>(
                    value: time,
                    // Use the label format from your screenshot
                    child: Text(_formatEndTimeLabel(time)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEndTime = value;
                    _validationError = null; // Clear error on new selection
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // --- CONFIRM BUTTON ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _selectedDay == null || _selectedStartTime == null || _selectedEndTime == null
                  ? null // Disable button if times aren't selected
                  : _onConfirmAndRequest,
                child: const Text('Confirm & Request'),
              ),

              // --- VALIDATION ERROR ---
              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _validationError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}