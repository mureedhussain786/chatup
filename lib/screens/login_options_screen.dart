import 'package:flutter/material.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to ChatUp'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone Login Button
              ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Login with Phone'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  // User ko phone login screen par bhej dein
                  Navigator.pushNamed(context, '/login');
                },
              ),
              const SizedBox(height: 20),

              // Email Login Button
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Login with Email'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  // User ko email login screen par bhej dein
                  Navigator.pushNamed(context, '/login_email');
                },
              ),
              const SizedBox(height: 30),
              const Text(
                'Note: Phone login might require setup. Email login is available now.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
