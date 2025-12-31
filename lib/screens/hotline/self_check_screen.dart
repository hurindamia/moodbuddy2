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
    SelfCheckQuestion(
        text: 'I felt overwhelmed by my academic responsibilities'),
    SelfCheckQuestion(text: 'I found it difficult to relax'),
    SelfCheckQuestion(text: 'I felt worried or uneasy without a clear reason'),
    SelfCheckQuestion(text: 'I lacked motivation for my usual activities'),
    SelfCheckQuestion(text: 'I felt emotionally drained'),
    SelfCheckQuestion(text: 'I had difficulty concentrating during lectures'),
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
                      max: 3,
                      divisions: 3,
                      label: q.score.toString(),
                      onChanged: (value) {
                        setState(() => q.score = value.toInt());
                      },
                    ),
                    const Text(
                      '0 = Never   •   3 = Most of the time',
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
              Navigator.pop(context, totalScore);
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
