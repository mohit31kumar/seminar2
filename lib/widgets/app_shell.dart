import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = appState.currentUser;
    final isAdmin = currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('P.U. Booking'),
        actions: [
          IconButton(
            icon: Icon(appState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<AppState>().toggleTheme(),
          ),
          if (currentUser != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'profile') context.go('/profile');
                if (value == 'logout') context.read<AppState>().logout();
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'profile', child: Text(currentUser.name)),
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Facilities'),
          const BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Booking'),
          if (isAdmin)
            const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin')
          else
             const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'My Bookings'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location == '/facilities') return 1;
    if (location == '/booking') return 2;
    if (location == '/admin' || location == '/my-bookings') return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final isAdmin = context.read<AppState>().currentUser?.role == 'admin';
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/facilities'); break;
      case 2: context.go('/booking'); break;
      case 3: context.go(isAdmin ? '/admin' : '/my-bookings'); break;
    }
  }
}