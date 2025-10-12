import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
// ignore: unused_import
import 'package:seminar_booking_app/models/booking.dart';

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
}
