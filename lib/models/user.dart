import 'package:flutter/foundation.dart';

@immutable
class User {
  final int id;
  final String name;
  final String email;
  final String department;
  final String role;
  final String password;
  final String? designation;
  final String? phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.password,
    this.designation,
    this.phone
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      department: json['department'] as String,
      role: json['role'] as String,
      password: json['password'] as String,
      designation: json['designation'] as String?,
      phone: json['phone'] as String?,
    );
  }
}