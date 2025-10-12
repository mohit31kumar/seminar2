import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:seminar_booking_app/providers/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for the AppState to finish its initial loading/auth check
    await Future.delayed(const Duration(milliseconds: 50)); // Small delay to ensure provider is ready
    final appState = context.read<AppState>();
    
    // Keep showing splash until the initial loading is complete
    while (appState.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (mounted) {
       // The redirect logic in GoRouter will handle the navigation
       // from here based on the login state. We just navigate away from splash.
       context.go(appState.isLoggedIn ? (appState.currentUser?.role == 'admin' ? '/admin/home' : '/') : '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Initializing App...'),
          ],
        ),
      ),
    );
  }
}