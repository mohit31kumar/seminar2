import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/booking.dart';
import '../data/initial_data.dart';

class AppState with ChangeNotifier {
  late SharedPreferences _prefs;

  bool _isLoggedIn = false;
  bool _isDarkMode = true;
  User? _currentUser;
  List<User> _users = [];
  Map<String, List<Booking>> _bookings = {};

  AppState() {
    _init();
  }

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isDarkMode => _isDarkMode;
  User? get currentUser => _currentUser;
  List<User> get users => _users;
  List<Booking> get allBookings => _bookings.values.expand((list) => list).toList();

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;

    final usersString = _prefs.getString('users');
    _users = (usersString != null)
        ? (json.decode(usersString) as List).map((data) => User.fromJson(data)).toList()
        : initialUsers.map((data) => User.fromJson(data)).toList();

    final bookingsString = _prefs.getString('bookings');
    if (bookingsString != null) {
      final Map<String, dynamic> decoded = json.decode(bookingsString);
      _bookings = decoded.map((key, value) =>
          MapEntry(key, (value as List).map((data) => Booking.fromJson(data)).toList()));
    } else {
      _bookings = initialBookings.map((key, value) =>
          MapEntry(key, (value as List).map((data) => Booking.fromJson(data)).toList()));
    }

    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}