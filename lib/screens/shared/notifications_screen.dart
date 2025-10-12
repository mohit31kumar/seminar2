import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final theme = Theme.of(context);

    // This check is a safeguard; routing should prevent unauthenticated access.
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please log in to see notifications.')),
      );
    }

    // Filter notifications for the current user and sort them by time.
    final userNotifications = appState.notifications
        .where((n) => n.userId == currentUser.uid)
        .toList();
    userNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: userNotifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'You have no notifications.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: userNotifications.length,
              itemBuilder: (context, index) {
                final notification = userNotifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: notification.isRead ? 0 : 2,
                  child: ListTile(
                    leading: Icon(
                      notification.isRead ? Icons.notifications_none_outlined : Icons.notifications_active,
                      color: notification.isRead ? Colors.grey : theme.colorScheme.primary,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(notification.body),
                    ),
                    trailing: Text(
                      DateFormat.yMd().add_jm().format(notification.timestamp),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                );
              },
            ),
    );
  }
}