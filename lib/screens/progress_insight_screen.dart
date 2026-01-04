import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

enum TimePeriod { week, month, year }

class MoodEntry {
  final DateTime date;
  final double moodScore;
  final double stressLevel;
  final double sleepHours;
  final Map<String, List<String>> shortcuts;

  MoodEntry({
    required this.date,
    required this.moodScore,
    required this.stressLevel,
    required this.sleepHours,
    required this.shortcuts,
  });

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      date: (data['date'] as Timestamp).toDate(),
      moodScore: (data['moodScore'] ?? 0).toDouble(),
      stressLevel: (data['stressLevel'] ?? 1).toDouble(),
      sleepHours: (data['sleepHours'] ?? 0).toDouble(),
      shortcuts: data.containsKey('shortcuts')
          ? (data['shortcuts'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, List<String>.from(v)),
      )
          : {},
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
  DateTime _focusedDate = DateTime.now();

  final double _sleepGoal = 8.0;
  final double _stressThreshold = 4.0;

  List<String> unlockedBadges = [];
  bool _isLoadingBadges = true;

  Future<void> _loadUnlockedBadges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('achievements')
        .get();

    setState(() {
      unlockedBadges = snap.docs.map((d) => d.id).toList();
      _isLoadingBadges = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMoodEntries();
    _loadUnlockedBadges();
  }

  Future<void> _loadMoodEntries() async {
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
          .orderBy('date', descending: false)
          .get();
      allEntries = snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error: $e');
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // --- LOGIC HELPERS ---

  double _calculateAverage(double Function(MoodEntry) selector) {
    final entries = _filteredEntries;
    if (entries.isEmpty) {
      return 0.0;
    }
    return entries.map(selector).reduce((a, b) => a + b) / entries.length;
  }

  List<MoodEntry> _filterBySpecificDate(DateTime focus, TimePeriod period) {
    return allEntries.where((entry) {
      if (period == TimePeriod.month) {
        return entry.date.month == focus.month && entry.date.year == focus.year;
      } else if (period == TimePeriod.year) {
        return entry.date.year == focus.year;
      } else {
        DateTime start = _getMonday(focus);
        DateTime end = start.add(const Duration(days: 7));
        return entry.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            entry.date.isBefore(end);
      }
    }).toList();
  }

  List<MoodEntry> get _filteredEntries => _filterBySpecificDate(_focusedDate, selectedPeriod);

  DateTime _getMonday(DateTime date) {
    DateTime d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  String _getEmoji(double mood) {
    if (mood <= 0) return '';
    if (mood <= 1.5) return '😄';
    if (mood <= 2.5) return '🙂';
    if (mood <= 3.5) return '😐';
    if (mood <= 4.5) return '🙁';
    return '😖';
  }

  void _showShortcutsDialog(MoodEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(DateFormat('EEEE, MMM d').format(entry.date),
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        content: entry.shortcuts.isEmpty
            ? const Text("No activities logged.")
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: entry.shortcuts.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text("${e.key}: ${e.value.join(', ')}",
                style: GoogleFonts.poppins(fontSize: 14)),
          )).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildProgressBar(String label, double value, double maxRange, Color color, {bool reverse = false}) {
    double percent = (value / maxRange).clamp(0.0, 1.0);
    if (reverse) {
      percent = (1.0 - percent).clamp(0.0, 1.0);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
              Text("${(percent * 100).toInt()}%", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // --- CHART BUILDERS ---

  LineTouchData _getLineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final date = _filteredEntries[spot.spotIndex].date;
              return LineTooltipItem(
                "${DateFormat('MMM d').format(date)}\nValue: ${spot.y.toStringAsFixed(1)}",
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          }
      ),
      touchCallback: (event, response) {
        if (event is FlTapUpEvent && response?.lineBarSpots != null) {
          _showShortcutsDialog(_filteredEntries[response!.lineBarSpots![0].spotIndex]);
        }
      },
    );
  }

  Widget _buildMoodChart() {
    return LineChart(LineChartData(
      lineTouchData: _getLineTouchData(),
      lineBarsData: [LineChartBarData(
        spots: _filteredEntries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.moodScore)).toList(),
        isCurved: true, color: const Color(0xFF9575CD), barWidth: 3, dotData: const FlDotData(show: true),
      )],
      titlesData: _chartTitles(),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      minY: 1, maxY: 5,
      minX: selectedPeriod == TimePeriod.week ? null : -0.5,
      maxX: selectedPeriod == TimePeriod.week ? null : _filteredEntries.length - 0.5,
    ));
  }

  Widget _buildStressChart() {
    return LineChart(LineChartData(
      lineTouchData: _getLineTouchData(),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
            y: _stressThreshold,
            color: Colors.orange.withValues(alpha: 0.3),
            strokeWidth: 2,
            dashArray: [5, 5],
            label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, labelResolver: (_) => "Limit")
        )
      ]),
      lineBarsData: [LineChartBarData(
        spots: _filteredEntries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.stressLevel)).toList(),
        isCurved: true, color: Colors.orange, barWidth: 3, dotData: const FlDotData(show: true),
      )],
      titlesData: _chartTitles(lInterval: 2, max: 10),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0, maxY: 10,
      minX: selectedPeriod == TimePeriod.week ? null : -0.5,
      maxX: selectedPeriod == TimePeriod.week ? null : _filteredEntries.length - 0.5,
    ));
  }

  Widget _buildSleepChart() {
    return BarChart(BarChartData(
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
            y: _sleepGoal,
            color: Colors.blue.withValues(alpha: 0.3),
            strokeWidth: 2,
            dashArray: [5, 5],
            label: HorizontalLineLabel(show: true, labelResolver: (_) => "Goal")
        )
      ]),
      barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = _filteredEntries[groupIndex].date;
                return BarTooltipItem(
                  "${DateFormat('MMM d').format(date)}\n${rod.toY} hrs",
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }
          ),
          touchCallback: (event, response) {
            if (event is FlTapUpEvent && response?.spot != null) {
              _showShortcutsDialog(_filteredEntries[response!.spot!.touchedBarGroupIndex]);
            }
          }
      ),
      barGroups: _filteredEntries.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.sleepHours, color: Colors.blue, width: 8)])).toList(),
      titlesData: _chartTitles(lInterval: 3, max: 12),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0, maxY: 12,
      alignment: BarChartAlignment.spaceAround,
    ));
  }

  FlTitlesData _chartTitles({double lInterval = 1, double max = 5}) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: selectedPeriod == TimePeriod.week,
              interval: 1,
              reservedSize: selectedPeriod == TimePeriod.week ? 30 : 10,
              getTitlesWidget: (v, m) {
                if (selectedPeriod != TimePeriod.week) return const SizedBox();
                int i = v.toInt();
                if (i < 0 || i >= _filteredEntries.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('d').format(_filteredEntries[i].date),
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              }
          )
      ),
      leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          interval: lInterval,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            if (value > max) return const SizedBox();
            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
          }
      )),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Map<String, String> _generatePatternInsights() {
    final current = _filteredEntries;
    if (current.isEmpty) {
      return {
        "trend": "Start logging to see patterns",
        "activity": "No habits identified yet",
        "mood": "Consistency is key!"
      };
    }

    double totalMood = _calculateAverage((e) => e.moodScore);
    double totalSleep = _calculateAverage((e) => e.sleepHours);
    Map<String, int> stressActivities = {};

    for (final entry in current) {
      if (entry.stressLevel >= 7) {
        for (final entryMap in entry.shortcuts.entries) {
          for (final item in entryMap.value) {
            stressActivities[item] = (stressActivities[item] ?? 0) + 1;
          }
        }
      }
    }

    String trendIndicator = "Avg mood is ${totalMood.toStringAsFixed(1)} ${_getEmoji(totalMood)}";
    if (totalMood <= 2.0) {
      trendIndicator += ". You're doing great!";
    } else if (totalMood >= 4.0) {
      trendIndicator += ". Take some time to rest.";
    }

    String topTrigger = stressActivities.isEmpty
        ? "no specific triggers"
        : stressActivities.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      "trend": trendIndicator,
      "activity": "Stress often occurs with '$topTrigger'.",
      "mood": "Avg Sleep: ${totalSleep.toStringAsFixed(1)}h.",
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || _isLoadingBadges) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avgMood = _calculateAverage((e) => e.moodScore);
    final avgStress = _calculateAverage((e) => e.stressLevel);
    final avgSleep = _calculateAverage((e) => e.sleepHours);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Progress Insight', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: const Color(0xFF9575CD),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodToggles(),
              const SizedBox(height: 15),
              _buildGlobalDateNav(),
              const SizedBox(height: 20),

              // --- WEEKLY SNAPSHOT ---
              _buildWeeklySnapshot(),
              const SizedBox(height: 25),

              // --- ALL CHARTS TOP ---
              _buildSectionTitle('Mood Trend'),
              _buildChartContainer(const Color(0xFFF8F4FF), _buildMoodChart()),
              const SizedBox(height: 25),

              _buildSectionTitle('Stress Levels'),
              _buildChartContainer(const Color(0xFFFFF8F0), _buildStressChart()),
              const SizedBox(height: 25),

              _buildSectionTitle('Sleep Duration'),
              _buildChartContainer(const Color(0xFFF0F7FF), _buildSleepChart()),
              const SizedBox(height: 35),

              // --- ALL PERCENTAGE BARS MIDDLE ---
              Text('Summary Scores', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildProgressBar("Happiness Level", 5 - avgMood, 4, const Color(0xFF9575CD)),
                    _buildProgressBar("Calmness Score", avgStress, 10, Colors.orange, reverse: true),
                    _buildProgressBar("Sleep Goal (${_sleepGoal}h)", avgSleep, _sleepGoal, Colors.blue),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- AI INSIGHTS BOTTOM ---
              Text('AI Insights & Trends', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildInsightSummaryCard(),
              const SizedBox(height: 40),

              ExpansionTile(
                title: Text(
                  "Achievements",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildAchievementsGrid(unlockedBadges),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalDateNav() {
    String label = selectedPeriod == TimePeriod.month
        ? DateFormat('MMMM yyyy').format(_focusedDate)
        : (selectedPeriod == TimePeriod.year
        ? DateFormat('yyyy').format(_focusedDate)
        : "Week of ${DateFormat('MMM d').format(_getMonday(_focusedDate))}");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() {
            if (selectedPeriod == TimePeriod.month) {
              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
            } else if (selectedPeriod == TimePeriod.year) {
              _focusedDate = DateTime(_focusedDate.year - 1);
            } else {
              _focusedDate = _focusedDate.subtract(const Duration(days: 7));
            }
          })),
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() {
            if (selectedPeriod == TimePeriod.month) {
              _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
            } else if (selectedPeriod == TimePeriod.year) {
              _focusedDate = DateTime(_focusedDate.year + 1);
            } else {
              _focusedDate = _focusedDate.add(const Duration(days: 7));
            }
          })),
        ],
      ),
    );
  }

  Widget _buildChartContainer(Color color, Widget chart) {
    if (_filteredEntries.isEmpty) {
      return Container(height: 100, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("No entries found")));
    }
    return Container(height: 220, padding: const EdgeInsets.fromLTRB(10, 20, 20, 10), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)), child: chart);
  }

  Widget _buildInsightSummaryCard() {
    final data = _generatePatternInsights();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9575CD), Color(0xFF673AB7)]), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        _insightItem(Icons.trending_up, data['trend']!),
        const Divider(color: Colors.white24, height: 20),
        _insightItem(Icons.star, data['activity']!),
        const Divider(color: Colors.white24, height: 20),
        _insightItem(Icons.analytics, data['mood']!)
      ]),
    );
  }

  Widget _insightItem(IconData icon, String text) {
    return Row(children: [Icon(icon, color: Colors.white70, size: 20), const SizedBox(width: 15), Expanded(child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)))]);
  }

  Widget _buildPeriodToggles() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(children: TimePeriod.values.map((p) => Expanded(child: GestureDetector(onTap: () => setState(() => selectedPeriod = p), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selectedPeriod == p ? const Color(0xFF9575CD) : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(p.name.toUpperCase(), style: TextStyle(color: selectedPeriod == p ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12))))))).toList()),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)));
  }

  Widget _buildWeeklySnapshot() {
    // Get the days to display and title
    DateTime startDay;
    String title;

    if (selectedPeriod == TimePeriod.week) {
      startDay = _getMonday(_focusedDate);
      title = 'Weekly Snapshot';
    } else if (selectedPeriod == TimePeriod.month) {
      // Days 1-7 of the month
      startDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
      title = 'First Week of the Month';
    } else {
      // Days 1-7 of the year
      startDay = DateTime(_focusedDate.year, 1, 1);
      title = 'First Week of the Year';
    }

    List<Widget> dayWidgets = [];
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = startDay.add(Duration(days: i));

      // Find mood entry for this day
      MoodEntry? dayEntry;
      try {
        dayEntry = allEntries.firstWhere(
                (entry) =>
            entry.date.year == currentDay.year &&
                entry.date.month == currentDay.month &&
                entry.date.day == currentDay.day
        );
      } catch (e) {
        dayEntry = null;
      }

      String emoji = dayEntry != null ? _getEmoji(dayEntry.moodScore) : '—';
      String dayName = DateFormat('E').format(currentDay).substring(0, 1);
      String dayNum = currentDay.day.toString();

      dayWidgets.add(
        Expanded(
          child: Column(
            children: [
              Text(
                dayName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dayEntry != null ? const Color(0xFFF8F4FF) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dayNum,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayWidgets,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(List<dynamic> unlockedBadges) {
    final achievements = [
      {
        'id': 'first_entry',
        'icon': Icons.emoji_events,
        'label': 'First Step',
      },
      {
        'id': 'going_strong',
        'icon': Icons.menu_book,
        'label': 'Going Strong',
      },
      {
        'id': 'consistent_creator',
        'icon': Icons.local_fire_department,
        'label': 'Consistent',
      },
      {
        'id': 'busy_bee',
        'icon': Icons.directions_run,
        'label': 'Busy Bee',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final badge = achievements[index];
        final unlocked = unlockedBadges.contains(badge['id']);

        return Column(
          children: [
            Opacity(
              opacity: unlocked ? 1 : 0.25,
              child: CircleAvatar(
                radius: 30,
                backgroundColor:
                unlocked ? Colors.purple : Colors.grey.shade800,
                child: Icon(
                  badge['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              badge['label'] as String,
              style: GoogleFonts.poppins(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}