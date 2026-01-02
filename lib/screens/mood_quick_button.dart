import 'package:flutter/material.dart';

class MoodQuickButtons extends StatelessWidget {
  final void Function(String mood) onMoodSelected;

  const MoodQuickButtons({
    super.key,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final moods = [
      {'emoji': '😊', 'value': 'happy'},
      {'emoji': '😐', 'value': 'neutral'},
      {'emoji': '😣', 'value': 'stressed'},
      {'emoji': '😭', 'value': 'sad'},
      {'emoji': '🤩', 'value': 'excited'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How are you feeling today?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),

        // --- Buttons Row ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.map((m) {
            return GestureDetector(
              onTap: () => onMoodSelected(m['value']!),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  m['emoji']!,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
