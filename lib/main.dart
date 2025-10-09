import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// --- Providers ---
// Manages the application's global state, including authentication,
// theme, users, and bookings.
import 'package:seminar2/providers/app_state.dart';

// --- Widgets ---
// A wrapper for the main UI that includes the AppBar and BottomNavigationBar.
import 'package:seminar2/widgets/app_shell.dart';

// --- Screens ---
// All the different pages/views of the application.
import 'package:seminar2/screens/splash_screen.dart';
import 'package:seminar2/screens/login_screen.dart';
import 'package:seminar2/screens/register_screen.dart';
import 'package:seminar2/screens/home_screen.dart';
import 'package:seminar2/screens/facilities_screen.dart';
import 'package:seminar2/screens/booking_screen.dart';
import 'package:seminar2/screens/my_bookings_screen.dart';
import 'package:seminar2/screens/admin_screen.dart';
import 'package:seminar2/screens/analytics_screen.dart';
import 'package:seminar2/screens/user_management_screen.dart';
import 'package:seminar2/screens/user_profile_screen.dart';

void main() {
  // Ensures that Flutter bindings are initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized(); 

  // Create a single instance of AppState to be used throughout the app.
  final appState = AppState();
  // Create the router, passing the AppState to it for managing redirects.
  final router = createRouter(appState);

  // Run the app, providing the AppState to the entire widget tree.
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: SeminarApp(router: router),
    ),
  );
}

/// Creates and configures the GoRouter instance for the application.
/// [appState] is used to listen for authentication changes and trigger redirects.
GoRouter createRouter(AppState appState) {
  return GoRouter(
    // The initial route to show when the app starts.
    initialLocation: '/splash',
    
    // The router will listen to AppState for any changes (like login/logout)
    // and re-evaluate its routes and redirects. This is the key to automatic
    // navigation after authentication.
    refreshListenable: appState,
    
    // Enables detailed navigation logging to the console during development.
    debugLogDiagnostics: true,
    
    routes: [
      // Standalone routes for pages that don't have the main app shell (AppBar, etc.).
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      /// A ShellRoute applies a common UI "shell" (in our case, `AppShell`)
      /// to all of its child routes. This is perfect for keeping the AppBar
      /// and BottomNavigationBar consistent across the main screens.
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/facilities', builder: (context, state) => const FacilitiesScreen()),
          GoRoute(path: '/booking', builder: (context, state) => const BookingScreen()),
          GoRoute(path: '/my-bookings', builder: (context, state) => const MyBookingsScreen()),
          GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
          GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
          GoRoute(path: '/user-management', builder: (context, state) => const UserManagementScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const UserProfileScreen()),
        ],
      ),
    ],

    /// This function runs before every navigation event to determine if a
    /// redirect is necessary based on the user's authentication state.
    redirect: (context, state) {
      final isLoggedIn = appState.isLoggedIn;
      final location = state.matchedLocation;

      // Routes that are part of the authentication flow.
      final isAuthPage = location == '/login' || location == '/register' || location == '/splash';

      // Rule 1: If the user is not logged in and is trying to access a protected
      // page, redirect them to the login screen.
      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }

      // Rule 2: If the user is already logged in, prevent them from accessing
      // the login or register pages again. Redirect them to the home screen.
      if (isLoggedIn && isAuthPage && location != '/splash') {
        return '/';
      }

      // Rule 3: If none of the above conditions are met, no redirect is needed.
      return null;
    },
  );
}

/// The root widget of the application.
class SeminarApp extends StatelessWidget {
  final GoRouter router;
  const SeminarApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in AppState to rebuild the widget when the theme changes.
    final appState = context.watch<AppState>();
    final baseTheme = Theme.of(context);

    return MaterialApp.router(
      title: 'Seminar Hall Booking',
      debugShowCheckedModeBanner: false,

      // Light Theme Configuration
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
      ),

      // Dark Theme Configuration
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // A slightly darker shade
        cardColor: const Color(0xFF1E293B),
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(baseTheme.primaryTextTheme),
      ),

      // The theme mode is dynamically controlled by the AppState.
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // The router configuration is passed to the MaterialApp.
      routerConfig: router,
    );
  }
}