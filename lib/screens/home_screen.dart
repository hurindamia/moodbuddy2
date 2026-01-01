import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'package:moodbuddy2/screens/mood_quick_button.dart';
import 'package:moodbuddy2/screens/progress_summary.dart';
import 'package:moodbuddy2/screens/featured_resource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        setState(() {
          username = doc['name'] ?? '';
        });
      }
    }
  }

  void _goTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  Widget _bigButton(BuildContext context,
      {required String title,
        required Color color,
        required String route,
        required IconData icon}) {
    return GestureDetector(
      onTap: () => _goTo(context, route),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Positioned.fill(child: Image.asset('assets/images/background1.png', fit: BoxFit.cover)),
        Positioned.fill(child: Container(color: Colors.black26)),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${username.isEmpty ? 'User' : username}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back — take a moment for yourself',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppTheme.primary),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Quote box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quote of the day',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        )),
                    const SizedBox(height: 8),
                    Text(
                      '"The best time to take care of your mind is now."',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('- MoodBuddy',
                          style: GoogleFonts.poppins(
                              color: Colors.black54, fontSize: 12)),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Mood Buttons
              MoodQuickButtons(
                onMoodSelected: (mood) {
                  Navigator.pushNamed(context, '/moodtracker');
                },
              ),

              const SizedBox(height: 24),

              // Progress Summary
              const ProgressSummaryCard(
                moodStreak: 5,
                journals: 3,
                progressPercentage: 0.6,
              ),

              const SizedBox(height: 24),

              // Featured Resources
              Text(
                'Featured Resources',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 12),
              FeaturedResourceCard(
                title: 'Coping with Stress — Click to read',
                onTap: () => Navigator.pushNamed(context, '/resources'),
              ),
              FeaturedResourceCard(
                title: '5 Ways to Improve Sleep Quality',
                onTap: () => Navigator.pushNamed(context, '/resources'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
