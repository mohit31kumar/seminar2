import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
// ignore: unused_import
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/models/notification.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER METHODS
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String department,
    required String employeeId,
  }) {
    // This method is called by AuthService during registration
    return _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'department': department,
      'employeeId': employeeId,
      'role': 'Faculty', // Default role
      'fcmTokens': [],
    });
  }

  Future<User?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? User.fromFirestore(doc) : null;
  }

  Stream<List<User>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }

  Future<void> saveUserToken(String userId, String token) {
    return _db.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayUnion([token])
    });
  }

  /// Updates a user's profile information in Firestore.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    // Ensure non-editable fields are not passed in the data map.
    data.remove('email');
    data.remove('employeeId');
    data.remove('role');

    return _db.collection('users').doc(uid).update(data);
  }

  /// Creates a user document, typically called by an admin.
  Future<void> createAdminUser({
    required String uid,
    required String name,
    required String email,
    required String department,
    required String employeeId,
    required String role,
  }) {
    return _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'department': department,
      'employeeId': employeeId,
      'role': role,
      'fcmTokens': [],
    });
  }

  Future<void> deleteUser(String uid) {
    return _db.collection('users').doc(uid).delete();
  }

  Future<void> updateUserRole(String uid, String newRole) {
    return _db.collection('users').doc(uid).update({'role': newRole});
  }

  // HALL METHODS
  Stream<List<SeminarHall>> getSeminarHalls() {
    return _db.collection('seminarHalls').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => SeminarHall.fromFirestore(doc)).toList());
  }

  Future<void> updateHallAvailability(String hallId, bool isAvailable) {
    return _db
        .collection('seminarHalls')
        .doc(hallId)
        .update({'isAvailable': isAvailable});
  }

  /// Creates a new document in the 'seminarHalls' collection.
  Future<void> addHall({
    required String name,
    required int capacity,
    required List<String> facilities,
  }) {
    return _db.collection('seminarHalls').add({
      'name': name,
      'capacity': capacity,
      'facilities': facilities,
      'isAvailable': true, // New halls are set to 'available' by default
    });
  }

  /// Updates an existing document in the 'seminarHalls' collection.
  Future<void> updateHall({
    required String hallId,
    required String name,
    required int capacity,
    required List<String> facilities,
  }) {
    return _db.collection('seminarHalls').doc(hallId).update({
      'name': name,
      'capacity': capacity,
      'facilities': facilities,
    });
  }

  // BOOKING METHODS

  Stream<List<Booking>> getBookings() {
    return _db.collection('bookings').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  Future<void> addBooking(Booking booking) {
    return _db.collection('bookings').add(booking.toJson());
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) {
    return _db.collection('bookings').doc(bookingId).update(data);
  }

  Future<void> cancelBooking(String bookingId) {
    return _db
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'Cancelled'});
  }

  // NOTIFICATION METHODS

  /// Gets a stream of notifications for a specific user.
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  Future<void> markNotificationsAsRead(List<String> notificationIds) {
    final batch = _db.batch();
    for (final id in notificationIds) {
      batch.update(_db.collection('notifications').doc(id), {'isRead': true});
    }
    return batch.commit();
  }
}
