import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityService {
  static Future<void> saveActivity({
    required DateTime date,
    required Map<String, dynamic> activityData,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activities')
        .doc(id)
        .set(activityData, SetOptions(merge: true));
  }
}
