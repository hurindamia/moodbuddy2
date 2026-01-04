import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TimePeriod { week, month, year }

class ProgressInsightScreen extends StatefulWidget {
  const ProgressInsightScreen({super.key});

  @override
  State<ProgressInsightScreen> createState() => _ProgressInsightScreenState();
}

class _ProgressInsightScreenState extends State<ProgressInsightScreen> {
  TimePeriod selectedPeriod = TimePeriod.week;

  String get _currentPeriodEmoji {
    if (selectedPeriod == TimePeriod.week) return '😌';
    if (selectedPeriod == TimePeriod.month) return '😊';
    return '😃';
  }

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
            // 1. Time Toggles
            _buildPeriodToggles(),
            const SizedBox(height: 20),

            // 2. Weekly Activity Row (The row matching your image)
            _buildWeeklyActivityRow(),
            const SizedBox(height: 25),

            // 3. Summary Card
            _buildSummaryReflectionCard(),
            const SizedBox(height: 25),

            // 4. Mood Chart
            Text(
              'Mood Trend Over ${selectedPeriod.name.toUpperCase()}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildChartPlaceholder(
              label: 'Mood Score (1-5)',
              color: const Color(0xFFF3E5F5),
              accentColor: const Color(0xFF9575CD),
            ),

            const SizedBox(height: 25),

            // 5. Stress Chart
            Text(
              'Stress Levels Over ${selectedPeriod.name.toUpperCase()}',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildChartPlaceholder(
              label: 'Stress Level (Low to High)',
              color: const Color(0xFFFFF3E0),
              accentColor: Colors.orange,
            ),

            const SizedBox(height: 25),

            // 6. Key Goal Progress
            Text(
              'Key Goal Progress',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProgressBar(
                title: 'Target Positivity Rate (75%)',
                currentValue: 0.75,
                color: Colors.green),
            _buildProgressBar(
                title: 'Stress Reduction Goal (Achieved: 5/7 days)',
                currentValue: 5 / 7,
                color: Colors.orange),
            _buildProgressBar(
                title: 'Sleep Consistency (Avg: 7.2 hrs)',
                currentValue: 0.85,
                color: Colors.blue),

            const SizedBox(height: 25),

            // 7. Actionable Reflection Boxes
            _buildReflectionBox(
              'Recurrent Stress Days: Your stress levels spiked on **Wednesdays**, matching your lowest mood entries.',
              Icons.warning_amber_rounded,
              const Color(0xFFFFCC80),
            ),
            const SizedBox(height: 15),
            _buildReflectionBox(
              'Sleep Impact: You logged **1.5 hours more sleep** on days following your highest mood ratings.',
              Icons.bedtime_outlined,
              const Color(0xFFBBDEFB),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildWeeklyActivityRow() {
    final List<Map<String, dynamic>> weeklyStatus = [
      {'day': 'M', 'date': '15', 'completed': true, 'emoji': '😊'},
      {'day': 'T', 'date': '16', 'completed': true, 'emoji': '😌'},
      {'day': 'W', 'date': '17/12', 'completed': true, 'emoji': '😐', 'isToday': true},
      {'day': 'T', 'date': '18', 'completed': false, 'emoji': ''},
      {'day': 'F', 'date': '19', 'completed': false, 'emoji': ''},
      {'day': 'S', 'date': '20', 'completed': false, 'emoji': ''},
      {'day': 'S', 'date': '21', 'completed': false, 'emoji': ''},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weeklyStatus.map((item) {
          bool isToday = item['isToday'] ?? false;
          return Column(
            children: [
              Text(
                item['day'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: item['day'] == 'S' && weeklyStatus.indexOf(item) == 6
                      ? Colors.red
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? const Color(0xFF9575CD).withOpacity(0.1) : Colors.transparent,
                  border: item['completed']
                      ? Border.all(color: Colors.greenAccent, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: item['completed'] ? Colors.white : Colors.grey[200],
                  child: Text(
                    item['emoji'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['date'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartPlaceholder({
    required String label,
    required Color color,
    required Color accentColor,
  }) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, color: accentColor, size: 40),
            Text(
              label,
              style: GoogleFonts.poppins(color: accentColor, fontWeight: FontWeight.w500),
            ),
          ],
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
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
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

  Widget _buildPeriodToggles() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: TimePeriod.values.map((period) {
          bool isSelected = selectedPeriod == period;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selectedPeriod = period),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF9575CD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period.name[0].toUpperCase() + period.name.substring(1),
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_currentPeriodEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mental Wellness Summary', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(_currentSummaryText, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
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
            child: Text(reflection, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}