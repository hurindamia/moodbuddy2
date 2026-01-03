import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<List<String>> processAchievements({
    required int totalEntries,
    required double stressLevel,
    required bool usedShortcuts,
  }) async {
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

    if (totalEntries >= 3) unlock('going_strong');
    if (totalEntries >= 15) unlock('consistent_creator');

    if (stressLevel >= 7 && usedShortcuts) {
      unlock('self_aware');
    }

    if (newlyUnlocked.isNotEmpty) {
      await userRef.update({'unlocked_badges': unlocked});
    }

    return newlyUnlocked;
  }
}
