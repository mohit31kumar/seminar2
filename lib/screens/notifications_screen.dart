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
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please log in to see notifications.')),
      );
    }

    final userNotifications = appState.notifications
        .where((n) => n.userId == currentUser.uid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: userNotifications.isEmpty
          ? const Center(
              child: Text('You have no notifications.'),
            )
          : ListView.builder(
              itemCount: userNotifications.length,
              itemBuilder: (context, index) {
                final notification = userNotifications[index];
                return ListTile(
                  leading: Icon(
                    notification.isRead ? Icons.notifications : Icons.notifications_active,
                    color: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
                  ),
                  title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(notification.body),
                  trailing: Text(
                    DateFormat.yMd().add_jm().format(notification.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
    );
  }
}