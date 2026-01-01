import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app_theme.dart';
import 'mood_quick_button.dart';
import 'progress_summary.dart';
import 'featured_resource.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';
  String sentiment = "NEUTRAL";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final moodSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_entries')
        .orderBy('last_updated', descending: true)
        .limit(1)
        .get();

    setState(() {
      username = userDoc.data()?['name'] ?? '';
      sentiment = moodSnap.docs.isNotEmpty
          ? moodSnap.docs.first['last_note_sentiment'] ?? "NEUTRAL"
          : "NEUTRAL";
      loading = false;
    });
  }

  // ================= FEATURED TITLES ONLY =================
  List<String> _featuredTitles(String sentiment) {
    if (sentiment == "NEGATIVE") {
      return [
        "Low Mood – Tips and Self-Help",
        "Stress Management Basics",
      ];
    }

    if (sentiment == "POSITIVE") {
      return [
        "Gratitude Journaling",
        "Building Positive Habits",
      ];
    }

    return [
      "Daily Self Check-In",
      "Mindful Breathing",
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final featuredTitles = _featuredTitles(sentiment);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black26, // overlay
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
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

                const SizedBox(height: 20),

                // Mood buttons
                MoodQuickButtons(
                  onMoodSelected: (_) {
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

                const SizedBox(height: 26),

                // Featured resources
                Text(
                  'Featured Resources',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Display each featured title as a card
                ...featuredTitles.map(
                      (title) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FeaturedResourceCard(
                      title: title, // pass the title
                      onTap: () {
                        // Redirect to resource library page
                        Navigator.pushNamed(context, '/resources');
                      },
                    ),
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
