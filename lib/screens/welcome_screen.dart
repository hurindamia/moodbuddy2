import 'package:flutter/material.dart';
import '../app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEE7F6), AppTheme.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text('Hi, User', style: TextStyle(fontFamily: 'TwCen', fontSize: 34, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 99, 47, 142))),
                const SizedBox(height: 8),
                const Text('Welcome back — take a moment for yourself', style: TextStyle(color: Color.fromARGB(179, 0, 0, 0))),
                const SizedBox(height: 30),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Illustration or emoji
                        Container(
                          width: 160,
                          height: 160,
                          child: const Center(child: Icon(Icons.mood, size: 180, color: Color.fromARGB(255, 99, 47, 142))),
                        ),
                        const SizedBox(height: 28),
                        const Text('MoodBuddy helps you track your emotions, reflect and get help when needed.',
                            style: TextStyle(color: Color.fromARGB(179, 0, 0, 0)), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 149, 126, 176), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Get Started', style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          // first open login or skip to main app:
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () { Navigator.pushReplacementNamed(context, '/home'); }, // guest access
                    child: const Text('Skip as guest', style: TextStyle(color: Colors.white70)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
