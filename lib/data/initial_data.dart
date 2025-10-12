const List<Map<String, dynamic>> initialUsers = [
  { "id": 1, "name": "Admin", "email": "admin@poornima.edu.in", "department": "Administration", "role": "admin", "password": "admin", "designation": "DSW", "phone": "1234567890" },
  { "id": 2, "name": "User", "email": "user@poornima.edu.in", "department": "Computer Science", "role": "user", "password": "user", "designation": "Professor", "phone": "0987654321" },
  { "id": 3, "name": "Aryan", "email": "aryan@poornima.edu.in", "department": "FCE", "role": "user", "password": "aryan", "designation": "Professor", "phone": "0987654333" }
];

const Map<String, List<Map<String, dynamic>>> initialBookings = {
  "2025-10-22": [
    {
      "id": 3, "title": "Intro to Machine Learning", "hall": "Ground Floor Seminar Hall",
      "date": "2025-10-22", "startTime": "11:00", "endTime": "12:00",
      "status": "pending", "requestedBy": "Faculty User", "email": "user@poornima.edu", "designation": "Professor",
      "department": "Computer Science", "phone": "0987654321", "purpose": "Guest lecture for B.Tech students.",
      "expectedAttendees": 150, "isInviteOnly": false,
      "guestName": "Dr. Eva Core", "guestDetails": "Lead AI Researcher at TechCorp",
      "adminNotes": "", "rejectionReason": null
    }
  ]
};