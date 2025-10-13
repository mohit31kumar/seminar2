import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:seminar_booking_app/providers/app_state.dart';

/// The main UI shell that wraps the primary screens of the app.
/// It provides a consistent AppBar and a dynamic BottomNavigationBar
/// that adapts based on the current user's role.
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final isAdmin = currentUser?.role == 'admin';
    final unreadCount = appState.unreadNotificationCount;

    // Display a loading screen for the entire app shell while the
    // initial user authentication check is in progress.
    if (appState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('P.U. Booking'),
        actions: [
          // Notification Icon with a badge for unread count
          IconButton(
            tooltip: 'Notifications',
            icon: badges.Badge(
              showBadge: unreadCount > 0,
              badgeContent: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              context.go('/notifications');
              // Mark notifications as read as soon as the user opens the screen
              Future.microtask(
                  () => context.read<AppState>().markNotificationsAsRead());
            },
          ),
          // User profile and logout menu
          if (currentUser != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Profile & Settings',
              onSelected: (value) {
                if (value == 'profile') context.go('/profile');
                if (value == 'logout') context.read<AppState>().logout();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Text(currentUser.name),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
        ],
      ),
      body: child, // The actual screen content is rendered here
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        currentIndex: _calculateSelectedIndex(context, isAdmin),
        onTap: (index) => _onItemTapped(index, context, isAdmin),
        items: _buildNavItems(isAdmin),
      ),
    );
  }

  /// Builds the list of navigation items based on the user's role.
  List<BottomNavigationBarItem> _buildNavItems(bool isAdmin) {
    if (isAdmin) {
      return const [
        BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined), label: 'Pending'),
        BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined), label: 'Manage Halls'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: 'Schedule'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined), label: 'Facilities'),
        BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline), label: 'Book Hall'),
        BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined), label: 'My Bookings'),
      ];
    }
  }

  /// Calculates the active index for the BottomNavigationBar.
  int _calculateSelectedIndex(BuildContext context, bool isAdmin) {
    final location = GoRouterState.of(context).matchedLocation;

    if (isAdmin) {
      if (location == '/admin/home') return 0;
      if (location == '/admin/halls') return 1;
      if (location == '/admin/bookings') return 2;
      // Group all other admin screens under the 'More' tab
      if (location == '/admin/users' || location == '/admin/analytics')
        return 3;
    } else {
      if (location == '/') return 0;
      if (location == '/facilities') return 1;
      // Group all booking flow screens under the 'Book Hall' tab
      if (location.startsWith('/booking')) return 2;
      if (location == '/my-bookings') return 3;
    }
    return 0; // Default to the first tab
  }

  /// Handles navigation when a bottom navigation item is tapped.
  void _onItemTapped(int index, BuildContext context, bool isAdmin) {
    if (isAdmin) {
      switch (index) {
        case 0:
          context.go('/admin/home');
          break;
        case 1:
          context.go('/admin/halls');
          break;
        case 2:
          context.go('/admin/bookings');
          break;
        case 3:
          // For admins, 'More' could lead to user management or analytics
          // Here, we'll default to User Management
          context.go('/admin/users');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/facilities');
          break;
        case 2:
          context.go('/booking');
          break;
        case 3:
          context.go('/my-bookings');
          break;
      }
    }
  }
}
