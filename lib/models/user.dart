import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the application.
/// This class is immutable and includes methods for converting
/// to and from Firestore documents.
class User {
  final String uid; // Corresponds to the Firebase Authentication UID
  final String name;
  final String email;
  final String department;
  final String role;
  final String employeeId;
  final List<String> fcmTokens; // List of device tokens for push notifications

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.employeeId,
    required this.fcmTokens,
  });

  /// Factory constructor to create a User instance from a Firestore document.
  /// This handles potential null values from the database gracefully.
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return User(
      uid: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      role: data['role'] ?? 'Faculty', // Defaults to 'Faculty' if not specified
      employeeId: data['employeeId'] ?? '',
      fcmTokens: List<String>.from(data['fcmTokens'] ?? []),
    );
  }

  /// Converts the User instance into a Map that can be written to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'role': role,
      'employeeId': employeeId,
      'fcmTokens': fcmTokens,
    };
  }
}