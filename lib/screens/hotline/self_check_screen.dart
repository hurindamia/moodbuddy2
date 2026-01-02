import 'package:flutter/material.dart';
import '../../models/self_check_question.dart';
import '../../app_theme.dart';

class SelfCheckScreen extends StatefulWidget {
  const SelfCheckScreen({super.key});

  @override
  State<SelfCheckScreen> createState() => _SelfCheckScreenState();
}

class _SelfCheckScreenState extends State<SelfCheckScreen> {
  final questions = [
    // STRESS
    SelfCheckQuestion(
      text: 'I felt overwhelmed by my academic workload',
      category: EmotionCategory.stress,
    ),
    SelfCheckQuestion(
      text: 'I felt under constant pressure to perform well',
      category: EmotionCategory.stress,
    ),
    SelfCheckQuestion(
      text: 'I felt emotionally exhausted at the end of the day',
      category: EmotionCategory.stress,
    ),

    // ANXIETY
    SelfCheckQuestion(
      text: 'I felt worried or uneasy without a clear reason',
      category: EmotionCategory.anxiety,
    ),
    SelfCheckQuestion(
      text: 'I felt anxious when thinking about deadlines',
      category: EmotionCategory.anxiety,
    ),
    SelfCheckQuestion(
      text: 'I felt restless or on edge',
      category: EmotionCategory.anxiety,
    ),

    // MOOD
    SelfCheckQuestion(
      text: 'I found it difficult to enjoy activities I usually like',
      category: EmotionCategory.mood,
    ),
    SelfCheckQuestion(
      text: 'I felt unmotivated to complete my tasks',
      category: EmotionCategory.mood,
    ),
    SelfCheckQuestion(
      text: 'I felt mentally tired even after resting',
      category: EmotionCategory.mood,
    ),
  ];

  int get totalScore =>
      questions.fold(0, (sum, q) => sum + q.score);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodBuddy Self-Check'),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Please indicate how often each statement applied to you recently.',
            style: TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 20),

          ...questions.map(
            (q) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.text,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: q.score.toDouble(),
                      min: 0,
                      max: 4,
                      divisions: 4,
                      label: q.score.toString(),
                      onChanged: (value) {
                        setState(() => q.score = value.toInt());
                      },
                    ),
                    const Text(
                      '0 = Never   •   1 = Rarely   •   2 = Sometimes   •   3 = Often   •   4 = Almost Always',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              int maxScore = questions.length * 4;
              double percentage = (totalScore / maxScore) * 100;

              Navigator.pop(context, {
                'totalScore': totalScore,
                'percentage': percentage,
                'questions': questions,
              });
            },
            child: const Text(
              'VIEW RESULT',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
