import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Your local imports
import 'firebase_options.dart';
import 'theme.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart' as auth_provider;
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Debug: Log Firebase Storage configuration
  if (kDebugMode) {
    final options = DefaultFirebaseOptions.currentPlatform;
    print('[Main] Firebase initialized');
    print('[Main] Project ID: ${options.projectId}');
    print('[Main] Storage Bucket: ${options.storageBucket}');
    print('[Main] Auth Domain: ${options.authDomain}');
  }

  runApp(const ChatUpApp());
}

/// ===============================
/// MAIN APP WIDGET
/// ===============================
class ChatUpApp extends StatelessWidget {
  const ChatUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => auth_provider.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'ChatUp',
            debugShowCheckedModeBanner: false,
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
              '/home': (_) => const WhatsAppHome(),
            },
          );
        },
      ),
    );
  }
}
