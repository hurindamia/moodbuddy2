import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class ProgressSummaryCard extends StatelessWidget {
  final int moodStreak;
  final int journals;
  final double progressPercentage; // 0.0 - 1.0

  const ProgressSummaryCard({
    super.key,
    required this.moodStreak,
    required this.journals,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Progress",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Mood streak & journals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallStat(title: "Mood Streak", value: "$moodStreak 🌟"),
              _smallStat(title: "Journals", value: "$journals 📝"),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Text(
            "Weekly Progress",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStat({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
