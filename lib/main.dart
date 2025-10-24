import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seminar_booking_app/services/auth_service.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';
import 'package:seminar_booking_app/services/push_notification_service.dart';
import 'firebase_options.dart';
import 'package:seminar_booking_app/config/theme.dart';
import 'package:seminar_booking_app/providers/app_state.dart';
import 'package:seminar_booking_app/widgets/app_shell.dart';
import 'package:seminar_booking_app/screens/auth/login_screen.dart';
import 'package:seminar_booking_app/screens/auth/register_screen.dart';
import 'package:seminar_booking_app/screens/shared/facilities_screen.dart';
import 'package:seminar_booking_app/screens/shared/profile_screen.dart';
import 'package:seminar_booking_app/screens/shared/notifications_screen.dart';
import 'package:seminar_booking_app/screens/faculty/home_screen_faculty.dart';
import 'package:seminar_booking_app/screens/faculty/booking_screen.dart';
import 'package:seminar_booking_app/screens/faculty/availability_checker_screen.dart';
import 'package:seminar_booking_app/screens/faculty/booking_form_screen.dart';
import 'package:seminar_booking_app/screens/faculty/my_bookings_screen.dart';
import 'package:seminar_booking_app/screens/faculty/booking_details_screen.dart';
import 'package:seminar_booking_app/screens/admin/home_screen_admin.dart';
import 'package:seminar_booking_app/screens/admin/booked_halls_screen.dart';
import 'package:seminar_booking_app/screens/admin/hall_management_screen.dart';
import 'package:seminar_booking_app/screens/admin/user_management_screen.dart';
import 'package:seminar_booking_app/screens/admin/analytics_screen.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/screens/admin/booking_history_screen.dart';
import 'package:seminar_booking_app/screens/admin/review_booking_screen.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:collection/collection.dart';
import 'package:seminar_booking_app/screens/admin/manage_hub_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize push notification service but don't save token yet
  await PushNotificationService().initialize();
  // Set up services to be provided
  final authService = AuthService();
  final firestoreService = FirestoreService();

  runApp(
    MultiProvider(
      providers: [
        // Make services available to the widget tree
        Provider.value(value: authService),
        Provider.value(value: firestoreService),
        // The main AppState provider that depends on the services
        ChangeNotifierProvider(
          create: (context) => AppState(
            authService: authService,
            firestoreService: firestoreService,
          ),
        ),
      ],
      child: const SeminarApp(),
    ),
  );
}

class SeminarApp extends StatefulWidget {
  const SeminarApp({super.key});

  @override
  State<SeminarApp> createState() => _SeminarAppState();
}

class _SeminarAppState extends State<SeminarApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _router = createRouter(appState);
  }

  @override
  Widget build(BuildContext context) {
    // Watch for theme changes in AppState
    final themeMode = context.select((AppState state) =>
        state.isDarkMode ? ThemeMode.dark : ThemeMode.light);

    // --- REVERTED ---
    // Removed the AnimatedSwitcher to prevent GlobalKey conflict
    return MaterialApp.router(
      title: 'Seminar Hall Booking',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      routerConfig: _router,
    );
    // --- END REVERTED ---
  }
}

GoRouter createRouter(AppState appState) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: appState,
    debugLogDiagnostics: true,
    routes: [
      // Standalone routes (no shell)
      // GoRoute(path: '/home', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()),

      // Main routes wrapped in the AppShell
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Shared Routes (accessible to both roles)
          GoRoute(
              path: '/facilities',
              builder: (context, state) => const FacilitiesScreen()),
          GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen()),
          GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen()),

          // Faculty Routes
          GoRoute(
              path: '/',
              builder: (context, state) => const FacultyHomeScreen()),
          GoRoute(
              path: '/my-bookings',
              builder: (context, state) => const MyBookingsScreen()),
          GoRoute(
            path: '/booking/details/:bookingId', // Uses path parameter
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId'];
              if (bookingId == null) {
                return const Scaffold(
                    body: Center(child: Text('Error: Booking ID missing.')));
              }
              final booking = context
                  .read<AppState>()
                  .bookings
                  .firstWhereOrNull((b) => b.id == bookingId);
              if (booking == null) {
                return Scaffold(
                    body: Center(
                        child: Text(
                            'Error: Booking with ID $bookingId not found.')));
              }
              return BookingDetailsScreen(booking: booking);
            },
          ),

          GoRoute(
              path: '/booking',
              builder: (context, state) => const BookingScreen()),
          GoRoute(
            path: '/booking/availability/:hallId', // Uses path parameter
            builder: (context, state) {
              final hallId = state.pathParameters['hallId'];
              if (hallId == null) {
                return const Scaffold(
                    body: Center(child: Text('Error: Hall ID missing.')));
              }
              final hall = context
                  .read<AppState>()
                  .halls
                  .firstWhereOrNull((h) => h.id == hallId);
              if (hall == null) {
                return Scaffold(
                    body: Center(
                        child: Text(
                            'Error: Hall with ID $hallId not found.')));
              }
              return AvailabilityCheckerScreen(hall: hall);
            },
          ),
          GoRoute(
            path: '/booking/form',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              if (extra == null) {
                return const Center(
                    child: Text('Error: Booking data not provided.'));
              }
              return BookingFormScreen(
                hall: extra['hall'],
                date: extra['date'],
                startTime: extra['startTime'],
                endTime: extra['endTime'],
              );
            },
          ),

          // Admin Routes
          GoRoute(
              path: '/admin/home',
              builder: (context, state) => const AdminHomeScreen()),
          GoRoute(
            path: '/admin/review/:bookingId',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId'];
              if (bookingId == null) {
                return const Scaffold(
                    body: Center(child: Text('Error: Booking ID missing.')));
              }
              final booking = context
                  .read<AppState>()
                  .bookings
                  .firstWhereOrNull((b) => b.id == bookingId);
              if (booking == null) {
                return Scaffold(
                    body: Center(
                        child: Text(
                            'Error: Booking with ID $bookingId not found.')));
              }
              return ReviewBookingScreen(booking: booking);
            },
          ),
          GoRoute(
              path: '/admin/bookings',
              builder: (context, state) => const BookedHallsScreen()),
          GoRoute(
              path: '/admin/halls',
              builder: (context, state) => const HallManagementScreen()),
          GoRoute(
              path: '/admin/history',
              builder: (context, state) => const BookingHistoryScreen()),
          
          GoRoute(
              path: '/admin/manage',
              builder: (context, state) => const ManageHubScreen()),

          GoRoute(
              path: '/admin/users',
              builder: (context, state) => const UserManagementScreen()),
          GoRoute(
              path: '/admin/analytics',
              builder: (context, state) => const AnalyticsScreen()),
        ],
      ),
    ],
    // --- Redirection Logic ---
    redirect: (context, state) {
      final isLoggedIn = appState.isLoggedIn;
      final role = appState.currentUser?.role;
      final location = state.matchedLocation;
      final isAuthPage = location == '/login' ||
          location == '/register' ||
          location == '/splash';

      // If user is not logged in and not on an auth page, redirect to register page
      if (!isLoggedIn && !isAuthPage) {
        return '/register';
      }

      // If user is logged in and on an auth page (after splash), redirect to their respective home screen
      if (isLoggedIn && isAuthPage && location != '/splash') {
        return role == 'admin' ? '/admin/home' : '/';
      }

      return null; // No redirect needed
    },
  );
}