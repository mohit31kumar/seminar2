import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:seminar_booking_app/models/user.dart';
import 'package:seminar_booking_app/services/firestore_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  /// A stream that listens for authentication state changes and provides the
  /// corresponding user profile from Firestore.
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      // When a user is logged in, fetch their profile from Firestore
      return await _firestoreService.getUser(firebaseUser.uid);
    });
  }

  /// Handles Google Sign-In.
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Authentication flow.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In cancelled by user.");
        return null; // Return null if user cancels
      }

      // 2. Perform email domain validation
      if (!googleUser.email.endsWith('@poornima.edu.in')) {
        print("Sign-in failed: Email domain is not allowed.");
        await _googleSignIn.signOut();
        throw auth.FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Only @poornima.edu.in emails are allowed.',
        );
      }

      // 3. Obtain the auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 4. Create a new credential for Firebase
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in to Firebase
      final auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return null; // Return null on failure
      }

      // 6. Check if user exists in Firestore, create if not
      User? appUser = await _firestoreService.getUser(firebaseUser.uid);
      if (appUser == null) {
        await _firestoreService.createUser(
          uid: firebaseUser.uid,
          name: googleUser.displayName ?? 'Poornima User',
          email: googleUser.email,
          department: 'Unknown', // Placeholder
          employeeId: '0000', // Placeholder
          role: 'Faculty',
        );
        appUser = await _firestoreService.getUser(firebaseUser.uid);
      }

      return appUser; // Return the Firestore user object

    } on auth.FirebaseAuthException catch (e) {
       print("Firebase Auth Exception during Google Sign-In: ${e.code} - ${e.message}");
       rethrow; // Re-throw the error to be caught by the UI
    } catch (e) {
      print("An unexpected error occurred during Google Sign-In: $e");
      return null;
    }
  }


  /// Handles self-registration for Faculty users.
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
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Admin-only function to create a new user.
  Future<String?> createUserByAdmin({
    required String email,
    required String password,
    required String name,
    required String department,
    required String employeeId,
    required String role,
  }) async {
    const tempAppName = 'tempAdminAppCreation';
    core.FirebaseApp? tempApp;

    try {
      tempApp = await core.Firebase.initializeApp(
        name: tempAppName,
        options: core.Firebase.app().options,
      );
      
      final tempAuth = auth.FirebaseAuth.instanceFor(app: tempApp);

      final credential = await tempAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (credential.user == null) {
        throw Exception("User creation failed in temporary Firebase app.");
      }

      await _firestoreService.createUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        department: department,
        employeeId: employeeId,
        role: role,
      );

      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      print("Admin user creation error: $e");
      return "An unexpected error occurred.";
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  /// Handles user sign-in.
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

  /// Sends a password reset email to the specified address.
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// Signs the current user out from both Firebase and Google.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _firebaseAuth.signOut(); // Sign out from Firebase
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  /// Calls a Cloud Function to delete a user from Firebase Auth.
  Future<String?> deleteUserByAdmin({required String uid}) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('deleteUser');
      await callable.call(<String, dynamic>{
        'uid': uid,
      });
      return null; // Success
    } on FirebaseFunctionsException catch (e) {
      return e.message;
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }
}