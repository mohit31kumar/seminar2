import 'package:flutter/foundation.dart';

@immutable
class Booking {
  final int id;
  final String title;
  final String hall;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String requestedBy;
  final String department;
  final int expectedAttendees;

  const Booking({
    required this.id,
    required this.title,
    required this.hall,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.requestedBy,
    required this.department,
    required this.expectedAttendees,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      title: json['title'] as String,
      hall: json['hall'] as String,
      date: json['date'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
      requestedBy: json['requestedBy'] as String,
      department: json['department'] as String,
      expectedAttendees: json['expectedAttendees'] as int,
    );
  }
}