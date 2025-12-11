import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

// --- MOCK DATA AND UTILS ---
enum TimePeriod { week, month, year }

// Mock data structure for the trend line
class MoodData {
  final String date;
  final double score;
  MoodData(this.date, this.score);
}

final List<MoodData> mockWeeklyData = [
  MoodData('Mon', 3.5),
  MoodData('Tue', 4.0),
  MoodData('Wed', 2.5),
  MoodData('Thu', 3.8),
  MoodData('Fri', 4.5),
  MoodData('Sat', 5.0),
  MoodData('Sun', 3.0),
];

// --- PROGRESS INSIGHT SCREEN ---

class ProgressInsightScreen extends StatefulWidget {
  const ProgressInsightScreen({super.key});

  @override
  State<ProgressInsightScreen> createState() => _ProgressInsightScreenState();
}

class _ProgressInsightScreenState extends State<ProgressInsightScreen> {
  TimePeriod selectedPeriod = TimePeriod.week;

  // Placeholder for the overall average mood emoji
  String get _currentPeriodEmoji {
    if (selectedPeriod == TimePeriod.week) return '😌';
    if (selectedPeriod == TimePeriod.month) return '😊';
    return '😃';
  }

  // Placeholder for the overall summary text
  String get _currentSummaryText {
    if (selectedPeriod == TimePeriod.week) {
      return 'A calm week overall. Focus days: Tuesday & Friday.';
    }
    if (selectedPeriod == TimePeriod.month) {
      return 'Solid progress! You achieved a 75% positive logging rate this month.';
    }
    return 'Great long-term stability. The trend shows increasing positivity over the year.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progress Insight',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF9575CD),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Time Period Toggles (Week | Month | Year)
            _buildPeriodToggles(),
            const SizedBox(height: 20),

            // 2. Summary & Reflection Section
            _buildSummaryReflectionCard(),
            const SizedBox(height: 25),

            // 3. Trend Line Chart (Placeholder)
            Text(
              'Mood Trend Over ${selectedPeriod.name.substring(0, 1).toUpperCase() + selectedPeriod.name.substring(1)}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTrendLineChartPlaceholder(),
            const SizedBox(height: 25),

            // 4. Progress Bars (Placeholder for Key Metrics)
            Text(
              'Key Goal Progress',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProgressBar(
              title: 'Target Positivity Rate (75%)',
              currentValue: 0.75, // 75%
              color: Colors.green,
            ),
            _buildProgressBar(
              title: 'Stress Reduction Goal (Achieved: 5/7 days)',
              currentValue: 5 / 7,
              color: Colors.orange,
            ),
            _buildProgressBar(
              title: 'Sleep Consistency (Avg: 7.2 hrs)',
              currentValue: 0.85, // Mock value
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            // 5. Data-Driven Reflection Box (Actionable Insight)
            _buildReflectionBox(
              'Recurrent Stress Days: Your lowest logged moods were consistently on **Wednesdays**. Consider scheduling a low-key activity mid-week.',
              Icons.warning_amber_rounded,
              const Color(0xFFFFCC80), // Light Orange
            ),
            const SizedBox(height: 15),
            _buildReflectionBox(
              'Positivity Increase: Your average mood increased by **15%** in the last month, correlating highly with your new evening journaling habit.',
              Icons.trending_up,
              const Color(0xFFC8E6C9), // Light Green
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildPeriodToggles() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: TimePeriod.values.map((period) {
          bool isSelected = selectedPeriod == period;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selectedPeriod = period),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF9575CD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period.name.substring(0, 1).toUpperCase() + period.name.substring(1),
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryReflectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentPeriodEmoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mental Wellness Summary',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentSummaryText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendLineChartPlaceholder() {
    // This is where a chart widget (e.g., from fl_chart) would go.
    // For now, it's a styled box to demonstrate the layout.
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF9575CD).withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          'Interactive Trend Line Chart Placeholder\n(Mood Score vs. Time)',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: const Color(0xFF9575CD), fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String title,
    required double currentValue,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: currentValue,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionBox(String reflection, IconData icon, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: backgroundColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF9575CD), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reflection,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}