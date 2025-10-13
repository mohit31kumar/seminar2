import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

/// A dialog for admins to re-allocate a booking to a different, available hall.
class ReallocateDialog extends StatefulWidget {
  final Booking conflictingBooking;

  const ReallocateDialog({super.key, required this.conflictingBooking});

  @override
  State<ReallocateDialog> createState() => _ReallocateDialogState();
}

class _ReallocateDialogState extends State<ReallocateDialog> {
  List<SeminarHall> _availableHalls = [];
  SeminarHall? _selectedHall;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Find available halls as soon as the dialog is shown.
    // Use a post-frame callback to safely access the provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findAvailableHalls();
    });
  }

  void _findAvailableHalls() {
    final appState = context.read<AppState>();
    final allBookings = appState.bookings;
    final allHalls = appState.halls;

    final conflictingStart = DateTime.parse(
        '${widget.conflictingBooking.date} ${widget.conflictingBooking.startTime}');
    final conflictingEnd = DateTime.parse(
        '${widget.conflictingBooking.date} ${widget.conflictingBooking.endTime}');

    final available = allHalls.where((hall) {
      // Exclude the original hall and any halls marked as unavailable for booking
      if (hall.name == widget.conflictingBooking.hall || !hall.isAvailable) {
        return false;
      }

      // Check for any overlapping bookings in this hall
      final hasOverlap = allBookings.any((booking) {
        if (booking.hall != hall.name ||
            (booking.status != 'Approved' && booking.status != 'Pending')) {
          return false;
        }
        final existingStart =
            DateTime.parse('${booking.date} ${booking.startTime}');
        final existingEnd =
            DateTime.parse('${booking.date} ${booking.endTime}');

        // Overlap condition: startA < endB and endA > startB
        return conflictingStart.isBefore(existingEnd) &&
            conflictingEnd.isAfter(existingStart);
      });

      return !hasOverlap;
    }).toList();

    setState(() {
      _availableHalls = available;
      _isLoading = false;
    });
  }

  Future<void> _submitReallocation() async {
    if (_selectedHall != null) {
      await context.read<AppState>().reviewBooking(
            bookingId: widget.conflictingBooking.id,
            newStatus: 'Approved',
            newHall: _selectedHall!.name,
          );

      if (mounted) {
        // Pop twice: once for the dialog, once for the review screen
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Re-allocate Booking'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _availableHalls.isEmpty
              ? const Text(
                  'No other halls are available during this time slot.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableHalls.length,
                    itemBuilder: (context, index) {
                      final hall = _availableHalls[index];
                      return RadioListTile<SeminarHall>(
                        title: Text(hall.name),
                        subtitle: Text('Capacity: ${hall.capacity}'),
                        value: hall,
                        groupValue: _selectedHall,
                        onChanged: (SeminarHall? value) {
                          setState(() {
                            _selectedHall = value;
                          });
                        },
                      );
                    },
                  ),
                ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          // Disable button if no hall is selected or none are available
          onPressed: _selectedHall != null ? _submitReallocation : null,
          child: const Text('Re-allocate & Approve'),
        ),
      ],
    );
  }
}
