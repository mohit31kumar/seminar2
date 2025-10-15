import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/models/notification.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 // USER METHODS
  // ✅ FIX: Added an optional 'role' parameter.
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String department,
    required String employeeId,
    String role = 'Faculty', // Defaults to 'Faculty' for self-registration
  }) {
    return _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'department': department,
      'employeeId': employeeId,
      'role': role, // Uses the provided role
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

/// Saare bookings ka stream fetch karta hai. Sirf ADMIN ke liye.
  Stream<List<Booking>> getAllBookings() {
    return _db.collection('bookings').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  /// Ek specific user ke bookings ka stream fetch karta hai. FACULTY ke liye.
  Stream<List<Booking>> getUserBookings(String uid) {
    return _db
        .collection('bookings')
        .where('requesterId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

 Future<void> addBooking(Booking booking) {
    return _db.collection('bookings').add(booking.toJson());
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) {
    return _db.collection('bookings').doc(bookingId).update(data);
  }

  Future<void> cancelBooking(String bookingId) {
    return _db.collection('bookings').doc(bookingId).update({'status': 'Cancelled'});
  }

  // NOTIFICATION METHODS

  /// Gets a stream of notifications for a specific user.
  Stream<List<AppNotification>> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }

  /// Sets the 'isRead' flag to true for a list of notification IDs.
  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    final batch = _db.batch();
    for (final id in notificationIds) {
      final docRef = _db.collection('notifications').doc(id);
      batch.update(docRef, {'isRead': true});
    }
    await batch.commit();
  }

   /// Calls a cloud function to securely change a user's role.
  Future<String?> changeUserRole({
    required String uid,
    required String newRole,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('changeUserRole');
      await callable.call(<String, dynamic>{
        'uid': uid,
        'newRole': newRole,
      });
      return null; // Success
    } on FirebaseFunctionsException catch (e) {
      return e.message; // Return error from the cloud function
    } catch (e) {
      return "An unexpected client-side error occurred.";
    }
  }
}