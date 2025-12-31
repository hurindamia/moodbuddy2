import 'package:cloud_firestore/cloud_firestore.dart';

class SelfCheckResult {
  final int totalScore;
  final double percentage;
  final Map<String, int> categoryScores;
  final DateTime date;

  SelfCheckResult({
    required this.totalScore,
    required this.percentage,
    required this.categoryScores,
    required this.date,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'totalScore': totalScore,
      'percentage': percentage,
      'categoryScores': categoryScores,
      'date': Timestamp.fromDate(date),
    };
  }

  factory SelfCheckResult.fromFirestore(Map<String, dynamic> data) {
    return SelfCheckResult(
      totalScore: data['totalScore'],
      percentage: data['percentage'],
      categoryScores: Map<String, int>.from(data['categoryScores']),
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
