import 'package:flutter/material.dart';
import '../app_theme.dart';

class ProgressInsightScreen extends StatelessWidget {
  const ProgressInsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // demo static data
    final data = [
      {'date': 'Day 1', 'score': 3},
      {'date': 'Day 2', 'score': 4},
      {'date': 'Day 3', 'score': 2},
      {'date': 'Day 4', 'score': 4},
      {'date': 'Day 5', 'score': 5},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Insight'), backgroundColor: AppTheme.primary),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Text('Mood Score (last 5)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // simple visual: horizontal bars
            ...data.map((d) {
              final score = d['score'] as int;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 70, child: Text(d['date'] as String)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha:0.3), borderRadius: BorderRadius.circular(8)),
                        child: FractionallySizedBox(
                          widthFactor: score / 5,
                          alignment: Alignment.centerLeft,
                          child: Container(decoration: BoxDecoration(color: AppTheme.primaryDark, borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(score.toString()),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
