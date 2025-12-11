import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    try {
      // Wait for 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Check if user is logged in
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      
      if (kDebugMode) {
        print('[SplashScreen] User logged in: $isLoggedIn');
      }
      
      if (!mounted) return;
      
      // Navigate to appropriate screen
      final route = isLoggedIn ? '/home' : '/login-options';
      Navigator.of(context).pushReplacementNamed(route);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[SplashScreen] Error during navigation: $e');
        print('[SplashScreen] StackTrace: $stackTrace');
      }
      // Fallback: navigate to login options on error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login-options');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show your logo with error handling
            SizedBox(
              width: 350,
              height: 350,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  if (kDebugMode) {
                    print('[SplashScreen] Error loading logo: $error');
                  }
                  // Fallback to icon if image fails
                  return const Icon(
                    Icons.chat_bubble_outline,
                    size: 200,
                    color: Colors.green,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ChatUp',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect. Chat. Share.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
