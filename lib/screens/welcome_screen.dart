import 'dart:async';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(begin: 0.95, end: 1.05).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );

    // Auto navigate after delay (optional)
    Timer(const Duration(seconds: 15), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Gradient Morph Background
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDAB8F4),
                  Color(0xFFC2A2D8),
                  Color(0xFFA884C1),
                ],
              ),
            ),
          ),

          // ☁️ Floating Clouds
          Positioned(
            top: 80,
            left: -40,
            child: _floatingCloud(),
          ),
          Positioned(
            bottom: 120,
            right: -60,
            child: _floatingCloud(delay: 1),
          ),

          // 🧠 Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulse Logo
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Image.asset(
                    'assets/images/moodbuddy_logo3.png',
                    height: 300,
                  ),
                ),

                const SizedBox(height: 30),


                const SizedBox(height: 10),

                const Text(
                  'Your mental wellbeing companion',
                  style: TextStyle(
                    fontFamily: 'TwCen',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // ⏭ Skip Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ☁️ Floating cloud widget
  Widget _floatingCloud({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -10, end: 10),
      duration: Duration(seconds: 4 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, value / 2),
          child: const Opacity(
            opacity: 0.25,
            child: Icon(
              Icons.cloud,
              size: 140,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
