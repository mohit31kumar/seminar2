import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> initialize() async {
    await _fcm.requestPermission();
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await getToken();
    if (token != null) {
      await _firestoreService.saveUserToken(userId, token);
    }

    _fcm.onTokenRefresh.listen((newToken) {
      if (userId.isNotEmpty) {
        _firestoreService.saveUserToken(userId, newToken);
      }
    });
  }
}