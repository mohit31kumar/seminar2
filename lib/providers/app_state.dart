import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seminar_booking_app/services/auth_service.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/models/notification.dart';

class AppState with ChangeNotifier {
  final AuthService authService;
  final FirestoreService firestoreService;

  User? _currentUser;
  bool _isLoading = true;
  bool _isDarkMode = true;
  List<SeminarHall> _halls = [];
  List<Booking> _bookings = [];
  List<AppNotification> _notifications = [];
  List<User> _allUsers = [];

  late StreamSubscription<User?> _authSubscription;
  StreamSubscription<List<SeminarHall>>? _hallsSubscription;
  StreamSubscription<List<Booking>>? _bookingsSubscription;
  StreamSubscription<List<User>>? _allUsersSubscription;
  StreamSubscription<List<AppNotification>>? _notificationsSubscription;

  // Public Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isDarkMode => _isDarkMode;
  List<SeminarHall> get halls => _halls;
  List<Booking> get bookings => _bookings;
  List<AppNotification> get notifications => _notifications;
  List<User> get allUsers => _allUsers;

  int get unreadNotificationCount {
    if (_currentUser == null) return 0;
    return _notifications
        .where((n) => n.userId == _currentUser!.uid && !n.isRead)
        .length;
  }

  AppState({required this.authService, required this.firestoreService}) {
    _authSubscription = authService.user.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    _isLoading = false;

    _hallsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _allUsersSubscription?.cancel();
    _notificationsSubscription?.cancel();

    if (user != null) {
      // General subscriptions for all users
      _hallsSubscription = firestoreService.getSeminarHalls().listen((halls) {
        _halls = halls;
        notifyListeners();
      });
      _notificationsSubscription =
          firestoreService.getNotifications(user.uid).listen((notifications) {
        _notifications = notifications;
        notifyListeners();
      });

      // Role-based subscriptions
      if (user.role == 'admin') {
        // Admin ko saare bookings aur saare users milenge
        _bookingsSubscription =
            firestoreService.getAllBookings().listen((bookings) {
          _bookings = bookings;
          notifyListeners();
        });
        _allUsersSubscription = firestoreService.getAllUsers().listen((users) {
          _allUsers = users;
          notifyListeners();
        });
      } else {
        // Faculty user ke liye
        // Faculty user ko sirf unke apne bookings milenge
        _bookingsSubscription =
            firestoreService.getUserBookings(user.uid).listen((bookings) {
          _bookings = bookings;
          notifyListeners();
        });
      }
    } else {
      // Logout par saara data clear karna
      _halls = [];
      _bookings = [];
      _allUsers = [];
      _notifications = [];
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    final user = await authService.signInWithEmailAndPassword(email, password);
    
    // If login fails, authStateChanges won't fire, so we manually stop loading.
    if (user == null) {
      _isLoading = false;
      notifyListeners();
    }
    return user != null;
    
  } catch (e) {
    // Also stop loading on any unexpected error
    _isLoading = false;
    notifyListeners();
    return false;
  }
  // Note: On successful login, _onAuthStateChanged will also set _isLoading = false,
  // which is fine.
}

  Future<void> logout() async {
    await authService.signOut();
  }

  /// Updates the current user's profile information.
  Future<void> updateUserProfile({
    required String name,
    required String department,
  }) async {
    if (_currentUser == null) return; // Safety check
    await firestoreService.updateUserProfile(_currentUser!.uid, {
      'name': name,
      'department': department,
    });
    // The real-time stream will automatically update the UI, so no notifyListeners() is needed here.
  }

  /// Calls the service to securely change a user's role via a Cloud Function.
  Future<String?> updateUserRole(String uid, String newRole) async {
    // This forwards the call to the firestoreService, which calls the cloud function.
    return await firestoreService.changeUserRole(uid: uid, newRole: newRole);
  }

  Future<void> submitBooking(Booking booking) async {
    await firestoreService.addBooking(booking);
  }

  Future<void> cancelBooking(String bookingId) async {
    await firestoreService.cancelBooking(bookingId);
  }

  /// Handles all admin actions on a booking (Approve, Reject, Re-allocate).
  Future<void> reviewBooking({
    required String bookingId,
    required String newStatus,
    String? rejectionReason,
    String? newHall,
  }) async {
    final updateData = <String, dynamic>{
      'status': newStatus,
    };
    if (rejectionReason != null) {
      updateData['rejectionReason'] = rejectionReason;
    }
    if (newHall != null) {
      updateData['hall'] = newHall;
    }
    await firestoreService.updateBooking(bookingId, updateData);
  }

  void markNotificationsAsRead() {
    if (_currentUser == null) return;
    final unreadIds =
        _notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isNotEmpty) {
      firestoreService.markNotificationsAsRead(unreadIds);
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _hallsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _allUsersSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.dispose();
  }
}
