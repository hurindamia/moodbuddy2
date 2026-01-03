import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'package:moodbuddy2/screens/mood_quick_button.dart';
import 'package:moodbuddy2/screens/progress_summary.dart';
import 'package:moodbuddy2/screens/featured_resource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodbuddy2/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';
  String userEmail = '';
  String emergencyName = '';
  String emergencyPhone = '';
  String? profileImageURL;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          userEmail = user.email ?? 'No Email Provided';
          if (doc.exists && doc.data() != null) {
            username = doc.data()!['name'] ?? '';
            emergencyName = doc.data()!['emergencyName'] ?? '';
            emergencyPhone = doc.data()!['emergencyPhone'] ?? '';
            profileImageURL = doc.data()!['profileImage'];
          } else {
            username = 'User';
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          username = 'Guest';
          userEmail = 'Not Logged In';
        });
      }
    }
  }

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          initialName: username.isEmpty ? 'User' : username,
          initialEmail: userEmail,
          initialEmergencyName: emergencyName,
          initialEmergencyPhone: emergencyPhone,
          initialImage: profileImageURL,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset('assets/images/background1.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black26),
        ),

        // Content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and Profile Avatar
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
                    GestureDetector(
                      onTap: () => _goToProfile(context),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: profileImageURL != null
                            ? NetworkImage(profileImageURL!)
                            : null,
                        child: profileImageURL == null
                            ? Icon(Icons.person, color: AppTheme.primary)
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Quote box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    // FIXED: Used withValues(alpha: 0.9) instead of withOpacity
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
                ProgressSummaryCard(
                  moodStreak: 5,
                  journals: 3,
                  progressPercentage: 0.6,
                ),

                const SizedBox(height: 24),

                // Featured Resources
                Text(
                  'Featured Resources',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white // Contrast adjustment for background
                  ),
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
        ),
      ],
    );
  }
}