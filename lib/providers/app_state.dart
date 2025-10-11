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
    return _notifications.where((n) => n.userId == _currentUser!.uid && !n.isRead).length;
  }
  
  AppState({required this.authService, required this.firestoreService}) {
    _authSubscription = authService.user.listen(_onAuthStateChanged, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    _isLoading = false;

    _hallsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _allUsersSubscription?.cancel();

    if (user != null) {
      _hallsSubscription = firestoreService.getSeminarHalls().listen((halls) {
        _halls = halls;
        notifyListeners();
      });
      
      // ✅ FIX: Changed from getUserBookings() to the correct getBookings()
      _bookingsSubscription = firestoreService.getBookings().listen((bookings) {
        _bookings = bookings;
        notifyListeners();
      });

      if (user.role == 'admin') {
        _allUsersSubscription = firestoreService.getAllUsers().listen((users) {
          _allUsers = users;
          notifyListeners();
        });
      }
    } else {
      _halls = [];
      _bookings = [];
      _allUsers = [];
    }
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final user = await authService.signInWithEmailAndPassword(email, password);
    return user != null;
  }
  
  Future<void> logout() async {
    await authService.signOut();
  }

  Future<void> submitBooking(Booking booking) async {
    await firestoreService.addBooking(booking);
  }

  Future<void> cancelBooking(String bookingId) async {
    await firestoreService.cancelBooking(bookingId);
  }
  
  // ✅ FIX: Added the missing reviewBooking method for admins
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
    // ...
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
    super.dispose();
  }
}