import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:seminar_booking_app/providers/app_state.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final isAdmin = currentUser?.role == 'admin';
    final unreadCount = appState.unreadNotificationCount;

    final location = GoRouterState.of(context).matchedLocation;

    const adminSubPages = {
      '/admin/halls',
      '/admin/users',
    };

    // Check if the current location is one of the sub-pages
    final bool isSubPage = isAdmin && adminSubPages.contains(location);
    // --- END OF NEW LOGIC ---

    if (appState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: isSubPage
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () {
                  // All sub-pages go back to the "Manage" hub
                  context.go('/admin/manage');
                },
              )
            : null,

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
              // Mark notifications as read when the user navigates to the screen
              context.read<AppState>().markNotificationsAsRead();
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
      // Admin navigation items
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month_rounded),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business_center_outlined),
          activeIcon: Icon(Icons.business_center_rounded),
          label: 'Manage',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics_rounded),
          label: 'Analytics',
        ),
      ];
    } else {
      // Faculty navigation items
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
      if (location == '/admin/bookings') return 1;

      // The "Manage" tab is now active for the hub, halls, and users.
      if (location == '/admin/manage' || // The new hub page
          location == '/admin/halls' || // The halls page
          location == '/admin/users') { // The users page
        return 2;
      }

      if (location == '/admin/analytics') return 3;
    } else {
      // Faculty logic
      if (location == '/') return 0;
      if (location == '/facilities') return 1;
      if (location.startsWith('/booking')) return 2;
      if (location == '/my-bookings') return 3;
    }
    return 0; // Default to the first tab
  }

  /// Handles navigation when a bottom navigation item is tapped.
  void _onItemTapped(int index, BuildContext context, bool isAdmin) {
    if (isAdmin) {
      switch (index) {
        case 0: // Dashboard
          context.go('/admin/home');
          break;
        case 1: // Schedule
          context.go('/admin/bookings');
          break;
        case 2: // Manage
          context.go('/admin/manage');
          break;
        case 3: // Analytics
          context.go('/admin/analytics');
          break;
      }
    } else {
      // Faculty logic
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