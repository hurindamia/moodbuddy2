import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
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

  List<dynamic> unlockedBadges = [];

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

  // ================= USER DATA =================
  Future<void> _loadUserData() async {
    if (user == null) {
      setState(() {
        username = 'Guest';
        userEmail = 'Not Logged In';
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      userEmail = user!.email ?? 'No Email';

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        username = data['name'] ?? 'User';
        emergencyName = data['emergencyName'] ?? '';
        emergencyPhone = data['emergencyPhone'] ?? '';
        profileImageURL = data['profileImage'];
        unlockedBadges = data['unlocked_badges'] ?? [];
      }
    });
  }

  // ================= MOOD STATS =================
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

    // --- WEEKLY ---
    final now = DateTime.now();
    final startOfWeek =
    DateTime(now.year, now.month, now.day - (now.weekday - 1)); // Monday

    final Set<String> weeklyDays = {};
    final Set<String> journalDays = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final dayKey = "${date.year}-${date.month}-${date.day}";

      // ===== STREAK =====
      if (lastDate == null ||
          lastDate.difference(DateTime(date.year, date.month, date.day)).inDays == 1) {
        streak++;
        lastDate = DateTime(date.year, date.month, date.day);
      } else {
        break;
      }


      // ===== WEEKLY CHECK =====
      if (date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
        weeklyDays.add(dayKey);

        // ===== JOURNAL CHECK =====
        final hasShortcuts =
            data['shortcuts'] != null && (data['shortcuts'] as Map).isNotEmpty;
        final hasNotes =
            data['notes'] != null && data['notes'].toString().trim().isNotEmpty;

        if (hasShortcuts || hasNotes) {
          journalDays.add(dayKey);
        }
      }
    }

    setState(() {
      moodStreak = streak;
      journalCount = journalDays.length;
      progressPercentage = weeklyDays.length / 7;
      loading = false;
    });
  }

  // ================= PROFILE NAV =================
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

  // ================= FEATURED TITLES =================
  List<String> _featuredTitles(String sentiment) {
    if (sentiment == "NEGATIVE") {
      return ["Low Mood – Tips and Self-Help", "Stress Management Basics"];
    }
    if (sentiment == "POSITIVE") {
      return ["Gratitude Journaling", "Building Positive Habits"];
    }
    return ["Daily Self Check-In", "Mindful Breathing"];
  }

  // ================= STREAK UI =================

  // Suggestion for a better Badge Widget
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
        // Tiny progress bar under the badge
        if (!achieved)
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 4),
            child: LinearProgressIndicator(value: current / target, color: Colors.purpleAccent),
          )
      ],
    );
  }

  void _showAchievementDialog(String title, String desc, int current, int nextLevel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Colors.purple, child: Icon(Icons.star, size: 40)),
            const SizedBox(height: 20),
            const Text("Congratulations!", style: TextStyle(color: Colors.white70)),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: current / nextLevel, color: Colors.purpleAccent),
            const SizedBox(height: 10),
            Text("Next level: $nextLevel", style: const TextStyle(color: Colors.white30)),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black26,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ===== HEADER =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $username',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                      onTap: _goToProfile,
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ===== QUOTE =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quote of the day',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"The best time to take care of your mind is now."',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '- MoodBuddy',
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showAchievementDialog(
                        "3-Day Streak",
                        "Maintain a 3-day mood streak",
                        moodStreak,
                        badgeTargets['3_day_streak']!,
                      ),
                      child: _buildBadge(
                        "3 Days",
                        Icons.local_fire_department,
                        moodStreak >= badgeTargets['3_day_streak']!,
                        moodStreak,
                        badgeTargets['3_day_streak']!,
                      ),
                    ),

                    const SizedBox(width: 12),

                    GestureDetector(
                      onTap: () => _showAchievementDialog(
                        "7-Day Streak",
                        "Maintain a 7-day mood streak",
                        moodStreak,
                        badgeTargets['7_day_streak']!,
                      ),
                      child: _buildBadge(
                        "7 Days",
                        Icons.whatshot,
                        moodStreak >= badgeTargets['7_day_streak']!,
                        moodStreak,
                        badgeTargets['7_day_streak']!,
                      ),
                    ),

                    const SizedBox(width: 12),

                    GestureDetector(
                      onTap: () => _showAchievementDialog(
                        "Journal Master",
                        "Write reflections on 5 different days",
                        journalCount,
                        badgeTargets['journal_5_days']!,
                      ),
                      child: _buildBadge(
                        "Journal",
                        Icons.menu_book,
                        journalCount >= badgeTargets['journal_5_days']!,
                        journalCount,
                        badgeTargets['journal_5_days']!,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                MoodQuickButtons(
                  onMoodSelected: (moodScore) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainLayout(
                            initialIndex: 1,        // switch to MoodTracker tab
                            initialMood: moodScore // pass emoji
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                ProgressSummaryCard(
                  moodStreak: moodStreak,
                  journals: journalCount,
                  progressPercentage: progressPercentage,
                ),

                const SizedBox(height: 26),
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
                      (title) => FeaturedResourceCard(
                    title: title,
                    onTap: () =>
                        Navigator.pushNamed(context, '/resources'),
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
