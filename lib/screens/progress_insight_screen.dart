import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

enum TimePeriod { week, month, year }

// 1. DATA MODEL (Matches your MoodTrackerScreen fields)
class MoodEntry {
  final DateTime date;
  final double moodScore;
  final double stressLevel;
  final double sleepHours;
  final List<String> activities;

  MoodEntry({
    required this.date,
    required this.moodScore,
    required this.stressLevel,
    required this.sleepHours,
    required this.activities,
  });

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Handle the 'shortcuts' map structure from your MoodTracker
    final shortcuts = data['shortcuts'] as Map<String, dynamic>? ?? {};
    final activityList = List<String>.from(shortcuts['activities'] ?? []);

    return MoodEntry(
      date: (data['date'] as Timestamp).toDate(),
      moodScore: (data['moodScore'] ?? 3.0).toDouble(),
      stressLevel: (data['stressLevel'] ?? 5.0).toDouble(),
      sleepHours: (data['sleepHours'] ?? 7.0).toDouble(),
      activities: activityList,
    );
  }
}

class ProgressInsightScreen extends StatefulWidget {
  const ProgressInsightScreen({super.key});

  @override
  State<ProgressInsightScreen> createState() => _ProgressInsightScreenState();
}

class _ProgressInsightScreenState extends State<ProgressInsightScreen> {
  TimePeriod selectedPeriod = TimePeriod.week;
  List<MoodEntry> allEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFirebaseData();
  }

  // 2. FIREBASE FETCHING LOGIC
  Future<void> _fetchFirebaseData() async {
    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mood_entries')
          .orderBy('date', descending: false) // Important for charts
          .get();

      allEntries = snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Error fetching insights: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  // 3. FILTERING LOGIC
  List<MoodEntry> get _filteredEntries {
    final now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod) {
      case TimePeriod.week: startDate = now.subtract(const Duration(days: 7)); break;
      case TimePeriod.month: startDate = now.subtract(const Duration(days: 30)); break;
      case TimePeriod.year: startDate = now.subtract(const Duration(days: 365)); break;
    }
    return allEntries.where((entry) => entry.date.isAfter(startDate)).toList();
  }

  // 4. ANALYTICS CALCULATIONS
  double get _avgMood => _filteredEntries.isEmpty ? 0 : _filteredEntries.map((e) => e.moodScore).reduce((a, b) => a + b) / _filteredEntries.length;
  double get _avgStress => _filteredEntries.isEmpty ? 0 : _filteredEntries.map((e) => e.stressLevel).reduce((a, b) => a + b) / _filteredEntries.length;
  double get _avgSleep => _filteredEntries.isEmpty ? 0 : _filteredEntries.map((e) => e.sleepHours).reduce((a, b) => a + b) / _filteredEntries.length;

  // Positivity rate: entries where mood is 1 or 2 (Happy/Great)
  double get _positivityRate => _filteredEntries.isEmpty ? 0 : _filteredEntries.where((e) => e.moodScore <= 2).length / _filteredEntries.length;

  String get _summaryEmoji {
    if (_avgMood == 0) return '😐';
    if (_avgMood <= 1.5) return '😁';
    if (_avgMood <= 2.5) return '😊';
    if (_avgMood <= 3.5) return '😐';
    return '😟';
  }

  String _getMoodEmoji(double score) {
    if (score <= 1) return '😁';
    if (score <= 2) return '😊';
    if (score <= 3) return '😐';
    if (score <= 4) return '😟';
    return '😢';
  }

  // === CHART HELPERS ===

  double _getLabelInterval() {
    switch (selectedPeriod) {
      case TimePeriod.week: return 1;
      case TimePeriod.month: return 5;
      case TimePeriod.year: return 30;
    }
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index < 0 || index >= _filteredEntries.length) return const SizedBox();

    final date = _filteredEntries[index].date;
    String text = selectedPeriod == TimePeriod.year
        ? DateFormat('MMM').format(date)
        : DateFormat('d').format(date);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.black54)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF9575CD))));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Progress Insight', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: const Color(0xFF9575CD),
        elevation: 0,
        actions: [IconButton(onPressed: _fetchFirebaseData, icon: const Icon(Icons.refresh, color: Colors.white))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodToggles(),
            const SizedBox(height: 25),

            Text('Current Week Activity', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildWeeklyHabitRow(),

            const SizedBox(height: 25),
            _buildSummaryCard(),

            const SizedBox(height: 30),
            _sectionTitle('Mood Trend'),
            _buildMoodChart(),

            const SizedBox(height: 30),
            _sectionTitle('Stress Levels'),
            _buildStressChart(),

            const SizedBox(height: 30),
            _sectionTitle('Key Goal Progress'),
            _buildProgressBar(title: 'Positivity Rate', currentValue: _positivityRate, color: Colors.green),
            _buildProgressBar(title: 'Sleep Consistency (Target 8h)', currentValue: _avgSleep / 8, color: Colors.blue),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // === WIDGET COMPONENTS ===

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text('$title (${selectedPeriod.name.toUpperCase()})',
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildPeriodToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: TimePeriod.values.map((period) {
          bool isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF9575CD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(period.name.toUpperCase(),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyHabitRow() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).add(Duration(days: index));

          // Check if user has an entry for this specific day
          final dayEntry = allEntries.cast<MoodEntry?>().firstWhere(
                (e) => e?.date.day == date.day && e?.date.month == date.month && e?.date.year == date.year,
            orElse: () => null,
          );

          bool isToday = date.day == now.day && date.month == now.month;

          return Column(
            children: [
              Text(DateFormat('E').format(date)[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 5),
              CircleAvatar(
                radius: 18,
                backgroundColor: dayEntry != null ? Colors.white : Colors.white.withOpacity(0.4),
                child: dayEntry != null
                    ? Text(_getMoodEmoji(dayEntry.moodScore), style: const TextStyle(fontSize: 18))
                    : const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(date.day.toString(), style: TextStyle(fontSize: 11, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMoodChart() {
    if (_filteredEntries.isEmpty) return _emptyState();
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(5, 20, 20, 10),
      decoration: BoxDecoration(color: const Color(0xFFF8F4FF), borderRadius: BorderRadius.circular(15)),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _filteredEntries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.moodScore)).toList(),
              isCurved: true, color: const Color(0xFF9575CD), barWidth: 3, dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF9575CD).withOpacity(0.1)),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: _getLabelInterval(), getTitlesWidget: _bottomTitles)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
          borderData: FlBorderData(show: false),
          minY: 1, maxY: 5, // Mood scale 1-5
        ),
      ),
    );
  }

  Widget _buildStressChart() {
    if (_filteredEntries.isEmpty) return _emptyState();
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(5, 20, 20, 10),
      decoration: BoxDecoration(color: const Color(0xFFFFF8F0), borderRadius: BorderRadius.circular(15)),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _filteredEntries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.stressLevel)).toList(),
              isCurved: true, color: Colors.orange, barWidth: 3, dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.1)),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: _getLabelInterval(), getTitlesWidget: _bottomTitles)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 2)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          minY: 1, maxY: 10, // Stress scale 1-10
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          Text(_summaryEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mental Wellness Summary', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                Text(
                    _filteredEntries.isEmpty
                        ? "Start logging to see your trends!"
                        : "Your average mood is ${(_avgMood).toStringAsFixed(1)}. You're doing great on consistency!",
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({required String title, required double currentValue, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${(currentValue * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(value: currentValue.clamp(0, 1), backgroundColor: Colors.grey[200], color: color, minHeight: 8, borderRadius: BorderRadius.circular(10)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
      child: Center(child: Text("No data for this period", style: GoogleFonts.poppins(color: Colors.grey))),
    );
  }
}