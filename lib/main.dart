import 'package:chatup/screens/chatup_home.dart';
import 'package:chatup/screens/email_login_screen.dart';
import 'package:chatup/screens/email_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your providers and screens
import 'firebase_options.dart'; // Auto-generated file
import 'providers/auth_provider.dart' as local_auth; // Alias to avoid conflict with Firebase Auth
import 'providers/theme_provider.dart';
import 'theme.dart';

// 1. IMPORT YOUR CHAT PROVIDER HERE (Check the file path)
import 'providers/chat_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => local_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // 2. ADD THIS LINE HERE:
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ChatUp',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthGate(),
            routes: {
              '/login_email': (context) => const EmailLoginScreen(),
              '/register_email': (context) => const EmailRegisterScreen(),
              '/home': (context) => const ChatUpHome(),
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const ChatUpHome();
        }
        return const EmailLoginScreen();
      },
    );
  }
}