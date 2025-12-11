import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import your providers and screens
import 'firebase_options.dart'; // Auto-generated file
import 'providers/auth_provider.dart'
    as local_auth; // Alias to avoid conflict with Firebase Auth
import 'providers/theme_provider.dart';
import 'theme.dart';

// 1. IMPORT YOUR CHAT PROVIDER HERE (Check the file path)
import 'providers/chat_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/chatup_home.dart';
import 'screens/phone_login_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/login_options_screen.dart';
import 'screens/email_login_screen.dart';
import 'screens/register_screen.dart';

/// ===============================
/// ENTRY POINT
/// ===============================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('[Main] Starting app initialization...');
  }

  try {
    if (kDebugMode) {
      print('[Main] Initializing Firebase...');
    }

    // Add timeout to prevent hanging
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (kDebugMode) {
          print('[Main] WARNING: Firebase initialization timed out');
        }
        throw TimeoutException('Firebase initialization timed out');
      },
    );

    // Debug: Log Firebase Storage configuration
    if (kDebugMode) {
      final options = DefaultFirebaseOptions.currentPlatform;
      print('[Main] Firebase initialized successfully');
      print('[Main] Project ID: ${options.projectId}');
      print('[Main] Storage Bucket: ${options.storageBucket}');
      print('[Main] Auth Domain: ${options.authDomain}');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('[Main] ERROR: Firebase initialization failed');
      print('[Main] Error: $e');
      print('[Main] StackTrace: $stackTrace');
    }
    // Continue anyway - some Firebase features might still work
  }

  if (kDebugMode) {
    print('[Main] Starting app...');
  }

  runApp(const MyApp());

  if (kDebugMode) {
    print('[Main] App started successfully');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            try {
              return local_auth.AuthProvider();
            } catch (e) {
              if (kDebugMode) print('[Main] Error creating AuthProvider: $e');
              rethrow;
            }
          }),
          ChangeNotifierProvider(create: (_) {
            try {
              return ThemeProvider();
            } catch (e) {
              if (kDebugMode) print('[Main] Error creating ThemeProvider: $e');
              rethrow;
            }
          }),
          ChangeNotifierProvider(create: (_) {
            try {
              return ChatProvider();
            } catch (e) {
              if (kDebugMode) print('[Main] Error creating ChatProvider: $e');
              rethrow;
            }
          }),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'ChatUp',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              initialRoute: '/splash',
              routes: {
                '/splash': (_) => const SplashScreen(),
                '/login-options': (_) => const LoginOptionsScreen(),
                '/login-email': (_) => const EmailLoginScreen(),
                '/register': (_) => const RegisterScreen(),
                '/login-phone': (_) => const PhoneLoginScreen(),
                '/verify': (_) => const OTPVerificationScreen(),
                '/home': (_) => const ChatUpHome(),
              },
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[Main] CRITICAL ERROR building app: $e');
        print('[Main] StackTrace: $stackTrace');
      }
      // Fallback: Show error screen
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('App initialization error'),
                const SizedBox(height: 8),
                if (kDebugMode) Text('$e'),
              ],
            ),
          ),
        ),
      );
    }
  }
}
