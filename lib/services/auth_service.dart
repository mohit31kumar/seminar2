import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _firestoreService.getUser(firebaseUser.uid);
    });
  }

  Future<String?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String department,
    required String employeeId,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        return "An unknown error occurred.";
      }
      await _firestoreService.createUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        department: department,
        employeeId: employeeId,
      );
      return null; // Success
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) return null;
      return await _firestoreService.getUser(credential.user!.uid);
    } catch (e) {
      return null;
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}