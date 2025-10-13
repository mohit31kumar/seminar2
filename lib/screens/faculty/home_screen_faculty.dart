import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

    final myBookings = appState.bookings
        .where((b) => b.requesterId == currentUser.uid)
        .toList();
    final pendingCount = myBookings.where((b) => b.status == 'Pending').length;
    final approvedCount =
        myBookings.where((b) => b.status == 'Approved').length;
    final rejectedCount =
        myBookings.where((b) => b.status == 'Rejected').length;

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
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.go('/booking'),
            ),
            const SizedBox(height: 24),

            // Summary section
            Text('My Requests Summary',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(context, 'Pending', pendingCount,
                        Colors.orange.shade700),
                    _buildStatChip(context, 'Approved', approvedCount,
                        Colors.green.shade700),
                    _buildStatChip(context, 'Rejected', rejectedCount,
                        Colors.red.shade700),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildUpcomingEvents(context, myBookings),
            const SizedBox(height: 24),
            _buildRecentActivity(context, myBookings),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for Dashboard Sections ---

  // Helper widget for the summary chips
  Widget _buildStatChip(
      BuildContext context, String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Text(
            count.toString(),
            style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  /// Builds the "Upcoming Events" section of the dashboard.
  Widget _buildUpcomingEvents(
      BuildContext context, List<dynamic> allMyBookings) {
    final theme = Theme.of(context);
    final today = DateUtils.dateOnly(DateTime.now());

    // Filter for approved bookings that are today or in the future
    final upcoming = allMyBookings
        .where((b) =>
            b.status == 'Approved' && !DateTime.parse(b.date).isBefore(today))
        .toList();

    // Sort by date and then by start time
    upcoming.sort((a, b) {
      int dateComp = a.date.compareTo(b.date);
      if (dateComp != 0) return dateComp;
      return a.startTime.compareTo(b.startTime);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upcoming Events',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (upcoming.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.event_busy_outlined),
              title: Text('No upcoming events'),
              subtitle: Text('Your approved bookings will appear here.'),
            ),
          )
        else
          ...upcoming.take(3).map((booking) {
            // Show up to 3 upcoming events
            final formattedDate =
                DateFormat.yMMMMd().format(DateTime.parse(booking.date));
            return Card(
              child: ListTile(
                leading: const Icon(Icons.event_available_outlined,
                    color: Colors.green),
                title: Text(booking.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${booking.hall}\n$formattedDate at ${booking.startTime}'),
                isThreeLine: true,
              ),
            );
          }),
      ],
    );
  }

  /// Builds the "Recent Activity" section of the dashboard.
  Widget _buildRecentActivity(
      BuildContext context, List<dynamic> allMyBookings) {
    final theme = Theme.of(context);

    // Sort all bookings by their creation time (implicitly, since they are added to a list)
    // For a real app, you'd sort by a 'createdAt' timestamp. Here we just reverse the list.
    final recent = allMyBookings.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.history_toggle_off_outlined),
              title: Text('No recent activity'),
              subtitle: Text('Your booking requests will appear here.'),
            ),
          )
        else
          ...recent.take(3).map((booking) {
            // Show up to 3 recent activities
            return Card(
              child: ListTile(
                leading: _getStatusIcon(booking.status, theme),
                title: Text(booking.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Status: ${booking.status}'),
                trailing:
                    Text(DateFormat.yMd().format(DateTime.parse(booking.date))),
              ),
            );
          }),
      ],
    );
  }

  /// Helper to get a status icon for the recent activity list.
  Widget _getStatusIcon(String status, ThemeData theme) {
    switch (status) {
      case 'Approved':
        return Icon(Icons.check_circle_outline, color: Colors.green.shade600);
      case 'Rejected':
        return Icon(Icons.cancel_outlined, color: Colors.red.shade600);
      case 'Cancelled':
        return Icon(Icons.do_not_disturb_on_outlined,
            color: Colors.grey.shade600);
      case 'Pending':
      default:
        return Icon(Icons.hourglass_top_outlined,
            color: Colors.orange.shade600);
    }
  }
}
