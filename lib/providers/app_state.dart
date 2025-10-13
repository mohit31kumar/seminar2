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
    _authSubscription =
        authService.user.listen(_onAuthStateChanged, onError: (error) {
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
    _notificationsSubscription?.cancel();

    if (user != null) {
      _hallsSubscription = firestoreService.getSeminarHalls().listen((halls) {
        _halls = halls;
        notifyListeners();
      });

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

      _notificationsSubscription =
          firestoreService.getNotifications(user.uid).listen((notifications) {
        _notifications = notifications;
        notifyListeners();
      });
    } else {
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
    final user = await authService.signInWithEmailAndPassword(email, password);
    return user != null;
  }

  Future<void> logout() async {
    await authService.signOut();
  }

  Future<void> updateUserProfile({
    required String name,
    required String department,
  }) async {
    if (_currentUser == null) return;
    await firestoreService.updateUserProfile(_currentUser!.uid, {
      'name': name,
      'department': department,
    });
  }

  Future<String?> addUser({
    required String name,
    required String email,
    required String employeeId,
    required String department,
    required String password,
    required String role,
  }) async {
    return await authService.createUserByAdmin(
      email: email,
      password: password,
      name: name,
      department: department,
      employeeId: employeeId,
      role: role,
    );
  }

  Future<void> deleteUser(String uid) async {
    await firestoreService.deleteUser(uid);
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await firestoreService.updateUserRole(uid, newRole);
  }

  Future<void> addHall({
    required String name,
    required int capacity,
    required List<String> facilities,
  }) async {
    await firestoreService.addHall(
      name: name,
      capacity: capacity,
      facilities: facilities,
    );
  }

  Future<void> updateHall({
    required String hallId,
    required String name,
    required int capacity,
    required List<String> facilities,
  }) async {
    await firestoreService.updateHall(
      hallId: hallId,
      name: name,
      capacity: capacity,
      facilities: facilities,
    );
  }

  Future<void> submitBooking(Booking booking) async {
    await firestoreService.addBooking(booking);
  }

  Future<void> cancelBooking(String bookingId) async {
    await firestoreService.cancelBooking(bookingId);
  }

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

  Future<void> markNotificationsAsRead() async {
    if (_currentUser == null) return;
    final unreadIds = _notifications
        .where((n) => n.userId == _currentUser!.uid && !n.isRead)
        .map((n) => n.id)
        .toList();
    if (unreadIds.isNotEmpty) {
      await firestoreService.markNotificationsAsRead(unreadIds);
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
