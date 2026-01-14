import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class ProgressSummaryCard extends StatelessWidget {
  final int totalMoodEntries;
  final int totalJournals;
  final double weeklyProgress; // 0.0 - 1.0

  const ProgressSummaryCard({
    super.key,
    required this.totalMoodEntries,
    required this.totalJournals,
    required this.weeklyProgress,
  });

  @override
  Widget build(BuildContext context) {
    final percentageLabel = "${(weeklyProgress * 100).round()}%";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
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
          // Title
          Text(
            "Today's Progress",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(height: 12),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallStat(
                title: "Mood Entries",
                value: "$totalMoodEntries",
                icon: Icons.emoji_emotions,
              ),
              _smallStat(
                title: "Journals Written",
                value: "$totalJournals",
                icon: Icons.menu_book,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekly Progress
          Text(
            "Weekly Check-In Progress ($percentageLabel)",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: weeklyProgress.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
