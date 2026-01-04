import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/main_layout.dart';
import 'profile_screen.dart';
import 'mood_quick_button.dart';
import 'progress_summary.dart';
import 'featured_resource.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  String username = '';
  String userEmail = '';
  String emergencyName = '';
  String emergencyPhone = '';
  String? profileImageURL;

  int moodStreak = 0;
  int journalCount = 0;
  double progressPercentage = 0.0;
  String sentiment = "NEUTRAL";

  bool loading = true;

  final Map<String, int> badgeTargets = {
    '3_day_streak': 3,
    '7_day_streak': 7,
    'journal_5_days': 5,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMoodStats();
  }

  // ================= DATA LOADING =================
  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (mounted && doc.exists) {
      setState(() {
        userEmail = user!.email ?? 'No Email';
        username = doc.data()?['name'] ?? 'User';
        emergencyName = doc.data()?['emergencyName'] ?? '';
        emergencyPhone = doc.data()?['emergencyPhone'] ?? '';
        profileImageURL = doc.data()?['profileImage'];
      });
    }
  }

  Future<void> _loadMoodStats() async {
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('mood_entries')
        .orderBy('date', descending: true)
        .get();

    int streak = 0;
    DateTime? lastDate;
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final Set<String> weeklyDays = {};
    final Set<String> journalDays = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final dayKey = "${date.year}-${date.month}-${date.day}";

      // Streak Logic
      if (lastDate == null || lastDate.difference(DateTime(date.year, date.month, date.day)).inDays == 1) {
        streak++;
        lastDate = DateTime(date.year, date.month, date.day);
      } else if (lastDate.difference(DateTime(date.year, date.month, date.day)).inDays > 1) {
        break;
      }

      // Weekly Progress & Sentiment
      if (date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
        weeklyDays.add(dayKey);
        if ((data['shortcuts'] != null && (data['shortcuts'] as Map).isNotEmpty) ||
            (data['notes'] != null && data['notes'].toString().trim().isNotEmpty)) {
          journalDays.add(dayKey);
        }
      }
    }

    if (mounted) {
      setState(() {
        moodStreak = streak;
        journalCount = journalDays.length;
        progressPercentage = weeklyDays.length / 7;
        loading = false;
      });
    }
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          initialName: username,
          initialEmail: userEmail,
          initialEmergencyName: emergencyName,
          initialEmergencyPhone: emergencyPhone,
          initialImage: profileImageURL,
        ),
      ),
    );
  }

  List<String> _featuredTitles(String sentiment) {
    if (sentiment == "NEGATIVE") return ["Low Mood – Tips and Self-Help", "Stress Management Basics"];
    if (sentiment == "POSITIVE") return ["Gratitude Journaling", "Building Positive Habits"];
    return ["Daily Self Check-In", "Mindful Breathing"];
  }

  // ================= UI COMPONENTS =================
  Widget _buildBadge(String label, IconData icon, bool achieved, int current, int target) {
    return Column(
      children: [
        Opacity(
          opacity: achieved ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: achieved ? Colors.purpleAccent : Colors.grey, width: 2),
              gradient: achieved ? const LinearGradient(colors: [Colors.pink, Colors.purple]) : null,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
        if (!achieved)
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 4),
            child: LinearProgressIndicator(value: (current / target).clamp(0.0, 1.0), color: Colors.purpleAccent),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background1.png'), // Using background1 from your first code
                fit: BoxFit.cover,
                opacity: 0.8,
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

                    // ================= GREETING (CENTERED) =================
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

                    const SizedBox(height: 24),

                    // Quote Card
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
                          Text('Quote of the day', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF9575CD))),
                          const SizedBox(height: 8),
                          Text('"The best time to take care of your mind is now."', style: GoogleFonts.poppins(fontSize: 16)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text('- MoodBuddy', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge("3 Days", Icons.local_fire_department, moodStreak >= 3, moodStreak, 3),
                        const SizedBox(width: 20),
                        _buildBadge("7 Days", Icons.whatshot, moodStreak >= 7, moodStreak, 7),
                        const SizedBox(width: 20),
                        _buildBadge("Journal", Icons.menu_book, journalCount >= 5, journalCount, 5),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Mood Selection Buttons
                    MoodQuickButtons(
                      onMoodSelected: (moodScore) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => MainLayout(initialIndex: 1, initialMood: moodScore)),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Progress Summary
                    ProgressSummaryCard(
                      moodStreak: moodStreak,
                      journals: journalCount,
                      progressPercentage: progressPercentage,
                    ),

                    const SizedBox(height: 26),

                    Text(
                      'Featured Resources',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ..._featuredTitles(sentiment).map((title) => FeaturedResourceCard(
                      title: title,
                      onTap: () => Navigator.pushNamed(context, '/resources'),
                    )),
                  ],
                ),
              ),
            ),
          ),

          // ================= PROFILE BUTTON (TOP RIGHT) =================
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: _goToProfile,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.account_circle, size: 42, color: Color(0xFF432560)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}