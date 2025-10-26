import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/models/seminar_hall.dart';
import 'package:seminar_booking_app/models/booking.dart';
import 'package:seminar_booking_app/models/notification.dart';

// ✅ IMPORT THE STORAGE SERVICE
import 'package:seminar_booking_app/services/storage_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // (User methods are unchanged)
  // ...
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String department,
    required String employeeId,
    String role = 'Faculty',
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

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    data.remove('email');
    data.remove('employeeId');
    data.remove('role');

    return _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) {
    return _db.collection('users').doc(uid).delete();
  }

  Future<void> updateUserRole(String uid, String newRole) {
    return _db.collection('users').doc(uid).update({'role': newRole});
  }

  // --- HALL METHODS (UPDATED) ---
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

  /// Creates a new hall document *without* an imageUrl.
  /// Returns the DocumentReference of the new hall.
  Future<DocumentReference> createHallDocument({
    required String name,
    required int capacity,
    required List<String> facilities,
    required String description,
  }) {
    return _db.collection('seminarHalls').add({
      'name': name,
      'capacity': capacity,
      'facilities': facilities,
      'description': description,
      'isAvailable': true,
      'imageUrl': '', // Set to empty string initially
    });
  }

  /// Adds or updates the imageUrl for a hall document.
  Future<void> updateHallImageUrl(String hallId, String imageUrl) {
    return _db
        .collection('seminarHalls')
        .doc(hallId)
        .update({'imageUrl': imageUrl});
  }


  /// Updates an existing document in the 'seminarHalls' collection.
  Future<void> updateHall({
    required String hallId,
    required String name,
    required int capacity,
    required List<String> facilities,
    required String description,
    required String imageUrl,
  }) {
    return _db.collection('seminarHalls').doc(hallId).update({
      'name': name,
      'capacity': capacity,
      'facilities': facilities,
      'description': description,
      'imageUrl': imageUrl,
    });
  }

  // --- ✅ THIS FUNCTION IS NOW FIXED ---
  /// Deletes a hall from the database.
  Future<void> deleteHall(String hallId) async {
    try {
      // 1. Get the document first to find its imageUrl
      final doc = await _db.collection('seminarHalls').doc(hallId).get();
      if (!doc.exists) return; // Hall already deleted
      
      final imageUrl = doc.data()?['imageUrl'] as String?;
    
      // 2. If an image URL exists, delete it from Storage
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final storageService = StorageService(); 
        await storageService.deleteImage(imageUrl);
      }
    
      // 3. Finally, delete the Firestore document
      await _db.collection('seminarHalls').doc(hallId).delete();
      
    } catch (e) {
      // If deleting the image fails, re-throw the error
      // so the user knows something went wrong.
      print('Error deleting hall: $e');
      rethrow;
    }
  }
  // --- END OF FIX ---

  // (Booking methods are unchanged)
  // ...
  Stream<List<Booking>> getAllBookings() {
    return _db.collection('bookings').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

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
    return _db
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'Cancelled'});
  }

  // (Notification methods are unchanged)
  // ...
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

  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    final batch = _db.batch();
    for (final id in notificationIds) {
      final docRef = _db.collection('notifications').doc(id);
      batch.update(docRef, {'isRead': true});
    }
    await batch.commit();
  }

  Future<String?> changeUserRole({
    required String uid,
    required String newRole,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('changeUserRole');
      await callable.call(<String, dynamic>{
        'uid': uid,
        'newRole': newRole,
      });

      // Also update the Firestore document
      await _db.collection('users').doc(uid).update({'role': newRole});

      return null; // Success
    } on FirebaseFunctionsException catch (e) {
      return e.message; // Return error from the cloud function
    } catch (e) {
      return "An unexpected client-side error occurred.";
    }
  }
}