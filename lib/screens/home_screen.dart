import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: unused_import
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

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final moodSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_entries')
        .orderBy('last_updated', descending: true)
        .limit(1)
        .get();

    if (!mounted) return;

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

    final List<String> featuredTitles = _featuredTitles(sentiment);

    return Scaffold(
      body: Stack(
        children: [
          // ================= BACKGROUND =================
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/purple2.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black26,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),

                    // ================= LOGO (CENTERED) =================
                    Center(
                      child: Image.asset(
                        'assets/images/moodbuddy_logo3.png',
                        height: 100,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= GREETING =================
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Hi, ${username.isEmpty ? 'User' : username} 👋',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Twcent',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Color(0xFF432560),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Welcome back — take a moment for yourself',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Twcent',
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= MOOD BUTTONS =================
                    MoodQuickButtons(
                      onMoodSelected: (_) {
                        Navigator.pushNamed(context, '/moodtracker');
                      },
                    ),

                    const SizedBox(height: 24),

                    // ================= PROGRESS SUMMARY =================
                    const ProgressSummaryCard(
                      moodStreak: 5,
                      journals: 3,
                      progressPercentage: 0.6,
                    ),

                    const SizedBox(height: 26),

                    // ================= FEATURED RESOURCES =================
                    Text(
                      'Featured Resources',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...featuredTitles.map(
                          (title) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FeaturedResourceCard(
                          title: title,
                          onTap: () {
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

          // ================= PROFILE BUTTON (MOVED HIGHER) =================
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_circle,
                  size: 42,
                  color: Color(0xFF432560),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
