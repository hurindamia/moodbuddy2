import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Main method to evaluate and unlock badges
  static Future<List<String>> evaluateAndUnlock({
    required Map<DateTime, List<double>> moodEntries,
    required double stressLevel,
    required bool sleepLogged,
    required bool usedShortcuts,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    // Get already unlocked badges
    List<String> unlocked = List<String>.from(doc.data()?['unlocked_badges'] ?? []);
    List<String> newlyUnlocked = [];

    void unlock(String id) {
      if (!unlocked.contains(id)) {
        unlocked.add(id);
        newlyUnlocked.add(id);
      }
    }

    final totalEntries = moodEntries.length;

    // --- BASIC ---
    if (totalEntries >= 1) unlock('first_entry');         // First Step
    if (totalEntries >= 30) unlock('going_strong');       // Going Strong

    // --- WELLNESS TRACKING ---
    if (totalEntries >= 14 && usedShortcuts) unlock('consistent_creator'); // Active Writer
    if (stressLevel > 0) unlock('stress_logger');        // Stress Aware
    if (sleepLogged) unlock('sleep_tracker');            // Sleep Tracker
    if (stressLevel > 0 && sleepLogged && totalEntries > 0) unlock('balanced_mind'); // Balanced Mind

    // --- STREAKS ---
    final streak = _calculateLongestStreak(moodEntries.keys.toList());
    if (streak >= 3) unlock('streak_3');
    if (streak >= 7) unlock('streak_7');
    if (streak >= 30) unlock('streak_30');
    if (streak >= 180) unlock('streak_180');
    if (streak >= 365) unlock('streak_365');

    // --- Update Firestore if new badges unlocked ---
    if (newlyUnlocked.isNotEmpty) {
      await userRef.update({'unlocked_badges': unlocked});
    }

    return newlyUnlocked;
  }

  /// Helper method to calculate the longest consecutive streak of days
  static int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    // Normalize dates (remove time part)
    final sorted = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList();
    sorted.sort();

    int longest = 1;
    int current = 1;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
      } else {
        current = 1;
      }
      if (current > longest) longest = current;
    }

    return longest;
  }

  // Streak evaluation function
  static Future<List<String>> evaluateStreak({
    required int currentStreak,
    required int streakGoal,
  }) async {
    // Example: unlock a streak badge
    final user = _auth.currentUser;
    if (user == null) return [];

    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();

    List<String> unlocked = List<String>.from(
      snapshot.data()?['unlocked_badges'] ?? [],
    );

    List<String> newlyUnlocked = [];

    void unlock(String id) {
      if (!unlocked.contains(id)) {
        unlocked.add(id);
        newlyUnlocked.add(id);
      }
    }

    if (currentStreak >= streakGoal) {
      unlock('streak_master'); // Example badge ID
    }

    if (newlyUnlocked.isNotEmpty) {
      await userRef.update({'unlocked_badges': unlocked});
    }

    return newlyUnlocked;
  }

  static final Map<String, int> streakMilestones = {
    'streak_3': 3,
    'streak_7': 7,
    'streak_30': 30,
    'streak_180': 180,
    'streak_365': 365,
  };

  /// Evaluate streaks and unlock all applicable streak badges
  static Future<Map<String, int>> evaluateStreakBadges(
      List<DateTime> entryDates) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    List<String> unlocked = List<String>.from(
      snapshot.data()?['unlocked_badges'] ?? [],
    );

    Map<String, int> newlyUnlocked = {}; // Badge ID -> milestone days

    // Calculate current longest streak
    int streak = _calculateLongestStreak(entryDates);

    // Check each milestone
    for (final entry in streakMilestones.entries) {
      final id = entry.key;
      final milestone = entry.value;
      if (streak >= milestone && !unlocked.contains(id)) {
        unlocked.add(id);
        newlyUnlocked[id] = milestone;
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await userRef.update({'unlocked_badges': unlocked});
    }

    return newlyUnlocked;
  }
}
