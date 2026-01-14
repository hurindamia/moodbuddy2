import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/foundation.dart'; // Required for setEquals
import '../services/achievement_service.dart';
import 'notes_screen.dart';
import 'journal_screen.dart';
import 'activities_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  final double? initialMood;

  const MoodTrackerScreen({
    super.key,
    this.initialMood,
  });

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // === STATE VARIABLES ===
  bool _isLoading = true;
  double _moodScore = 0;
  double _stressLevel = 0;
  int _sleepHour = 0;
  int _sleepMinute = 0;
  bool _initiallyHadEntry = false;
  bool _hasEntryForSelectedDay = false;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final Map<DateTime, List<double>> _events = {};
  final Map<String, bool> _expandedSections = {};

  // Shortcuts logic
  Map<String, List<String>> shortcutOptions = {
    "Emotions / Sensations": ["grateful", "tired", "anxious", "angry", "unsure"],
    "Health": ["exercise", "drink water", "walk", "sports", "massage"],
    "Social": ["family", "partner", "friends"],
    "Actions": ["travel", "read", "gaming", "shopping", "working"],
    "Weather": ["sunny", "cloudy", "windy", "rainy"],
  };

  Map<String, Set<String>> selectedShortcuts = {};

  // Tracking for Unsaved Changes
  double _initialMood = 0;
  double _initialStress = 0;
  int _initialSleepHour = 0;
  int _initialSleepMinute = 0;
  Map<String, Set<String>> _initialShortcuts = {};

  double? selectedMood;

  @override
  void initState() {
    super.initState();
    for (final k in shortcutOptions.keys) {
      _expandedSections[k] = true;
    }
    for (final key in shortcutOptions.keys) {
      selectedShortcuts[key] = <String>{};
    }
    if (widget.initialMood != null) {
      _moodScore = widget.initialMood!;
    }
    _loadShortcutVocabulary();
    _loadAllEntries();
    _loadEntryForDay();
  }

  // ================= FIREBASE LOGIC =================

  Future<void> _loadAllEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_entries')
        .get();

    _events.clear();
    for (var doc in snap.docs) {
      final date = (doc['date'] as Timestamp).toDate();
      final d = DateTime(date.year, date.month, date.day);
      _events[d] = [doc['moodScore'].toDouble()];
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadEntryForDay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_entries')
        .doc(id)
        .get();

    if (mounted) {
      setState(() {
        selectedShortcuts.clear();
        _hasEntryForSelectedDay = doc.exists;
        _initiallyHadEntry = doc.exists;

        if (doc.exists) {
          final data = doc.data()!;
          _moodScore = (data['moodScore'] ?? 0).toDouble();
          _stressLevel = (data['stressLevel'] ?? 0).toDouble();
          final sleep = (data['sleepHours'] ?? 0).toDouble();
          _sleepHour = sleep.floor();
          _sleepMinute = ((sleep - _sleepHour) * 60).round();

          if (data.containsKey('shortcuts')) {
            (data['shortcuts'] as Map<String, dynamic>).forEach((k, v) {
              selectedShortcuts[k] = Set<String>.from(v);
            });
          }
        } else {
          // RESET TO DEFAULTS for empty days
          _moodScore = widget.initialMood ?? 0;
          _stressLevel = 0;
          _sleepHour = 0;
          _sleepMinute = 0;
        }

        for (final key in shortcutOptions.keys) {
          selectedShortcuts[key] ??= <String>{};
        }

        // Capture initial state for change tracking
        _initialMood = _moodScore.roundToDouble();
        _initialStress = _stressLevel.roundToDouble();
        _initialSleepHour = _sleepHour;
        _initialSleepMinute = _sleepMinute;
        _initialShortcuts = {
          for (final e in selectedShortcuts.entries)
            e.key: Set<String>.from(e.value)
        };

        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, String>>> _getStreakAchievements() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final entriesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_entries')
        .orderBy('date', descending: true)
        .get();

    if (entriesSnap.docs.isEmpty) return [];

    final entryDates = entriesSnap.docs
        .map((doc) => (doc['date'] as Timestamp).toDate())
        .toList();

    // Unlock streak badges and get newly unlocked
    final newlyUnlockedStreaks =
    await AchievementService.evaluateStreakBadges(entryDates);

    // Convert to popup-friendly format
    final streakAchievements = newlyUnlockedStreaks.entries.map((entry) {
      final milestone = entry.value;
      String encouragement;

      if (milestone == 3) {
        encouragement = "Awesome! 3 days in a row!";
      } else if (milestone == 7) {
        encouragement = "1-week streak! Keep going!";
      } else if (milestone == 14) {
        encouragement = "2 weeks streak! You're doing great!";
      } else if (milestone == 30) {
        encouragement = "30-day streak! Incredible dedication!";
      } else {
        encouragement = "$milestone-day streak! Amazing dedication!";
      }

      return {
        'title': 'Streak Milestone!',
        'desc': encouragement,
      };
    }).toList();

    return streakAchievements;
  }

  Future<void> _saveEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id = DateFormat('yyyy-MM-dd').format(_selectedDay);

    // Determine if it's a "negative day" for tracking
    final bool isNegativeDay = _moodScore >= 4 || _stressLevel >= 7;

    // Save mood entry to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_entries')
        .doc(id)
        .set({
      'moodScore': _moodScore,
      'stressLevel': _stressLevel,
      'sleepHours': _sleepHour + (_sleepMinute / 60),
      'date': Timestamp.fromDate(_selectedDay),
      'shortcuts': selectedShortcuts.map((k, v) => MapEntry(k, v.toList())),
      'isNegativeDay': isNegativeDay,
    });

    // Reload calendar & day entry
    await _loadAllEntries();
    await _loadEntryForDay();

    // After saving entry, before achievements
    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_people, color: Colors.blue, size: 60),
              const SizedBox(height: 16),
              Text(
                "Great job!",
                style: GoogleFonts.poppins(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                "You just recorded your mood for today. Hope you are doing fine! 🌟",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Thanks!", style: GoogleFonts.poppins(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    // --- Get regular achievements ---
    final newlyUnlocked = await AchievementService.evaluateAndUnlock(
      moodEntries: _events,
      stressLevel: _stressLevel,
      sleepLogged: _sleepHour > 0 || _sleepMinute > 0,
      usedShortcuts: selectedShortcuts.values.any((s) => s.isNotEmpty),
    );

    final regularAchievements = newlyUnlocked.map((id) => {
      'title': _badgeTitle(id),
      'desc': _badgeDescription(id),
    }).toList();

    // --- Get streak achievements ---
    final streakAchievements = await _getStreakAchievements();

    // --- Combine all achievements into one queue ---
    final allAchievements = [...regularAchievements, ...streakAchievements];

    // --- Show popups sequentially ---
    if (mounted && allAchievements.isNotEmpty) {
      await _showAchievementsSequentially(allAchievements);
    }

    // --- Show confirmation Snackbar ---
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mood entry saved successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id = DateFormat('yyyy-MM-dd').format(_selectedDay);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_entries')
        .doc(id)
        .delete();

    await _loadAllEntries();
    await _loadEntryForDay();
  }

  Future<void> _loadShortcutVocabulary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('preferences')
        .doc('shortcut_vocab')
        .get();

    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return; // Add a null check here
    setState(() {
      data.forEach((key, value) {
        shortcutOptions[key] = List<String>.from(value);
      });
    });
  }

  Future<void> _saveShortcutVocabulary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('preferences')
        .doc('shortcut_vocab')
        .set(shortcutOptions);
  }

  // ================= UI HELPERS =================

  void _addCustomKeyword(String category) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Keyword"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter keyword")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  shortcutOptions[category]!.add(text);
                });
                _saveShortcutVocabulary(); // persist globally
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (_hasUnsavedChanges) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Unsaved Changes"),
          content: const Text("You have unsaved changes for this day. Discard them?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Discard")),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    await _loadEntryForDay();
  }

  bool get _hasUnsavedChanges {
    if (!_initiallyHadEntry &&
        _moodScore == 0 &&
        _stressLevel == 0 &&
        _sleepHour == 0 &&
        _sleepMinute == 0 &&
        selectedShortcuts.values.every((s) => s.isEmpty)) {
      return false;
    }

    if (_moodScore.round() != _initialMood.round()) return true;
    if (_stressLevel.round() != _initialStress.round()) return true;
    if (_sleepHour != _initialSleepHour) return true;
    if (_sleepMinute != _initialSleepMinute) return true;

    for (final key in selectedShortcuts.keys) {
      if (!setEquals(selectedShortcuts[key], _initialShortcuts[key] ?? {})) {
        return true;
      }
    }
    return false;
  }

  void _navigateWithConfirmation(
      BuildContext context, {
        required String title,
        required String description,
        required WidgetBuilder builder,
      }) async {
    final continueNavigation = await _showPageConfirmation(
      title: title,
      description: description,
    );

    if (!mounted) return; // ❌ check if widget is still alive

    if (continueNavigation == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: builder),
      );
    }
  }

  Future<bool?> _showPageConfirmation({
    required String title,
    required String description,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, color: Colors.blueAccent, size: 50),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.poppins(
                    color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text("Cancel",
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text("Continue",
                        style: GoogleFonts.poppins(
                            color: Colors.blueAccent, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAchievementPopup(String title, String desc, {int current = 1, int next = 1}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A), // Dark themed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.blue, size: 80),
            const SizedBox(height: 16),
            Text("Congratulations!",
                style: GoogleFonts.poppins(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: current / next,
                backgroundColor: Colors.white10,
                color: Colors.purpleAccent,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 10),
            Text("Next level: $next entries",
                style: GoogleFonts.poppins(color: Colors.white30, fontSize: 12)),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("AWESOME!", style: GoogleFonts.poppins(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showAchievementsSequentially(List<Map<String, String>> achievements) async {
    for (final ach in achievements) {
      await _showAchievementPopup(ach['title']!, ach['desc']!);
    }
  }

  // ================= BUILD METHOD =================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Tracker", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color(0xFF9575CD),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            opacity: 0.35,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _jumpControl(),
              const SizedBox(height: 10),
              _calendar(),
              const SizedBox(height: 30),
              _section("How are you feeling?"),
              _moodScale(),
              const SizedBox(height: 30),
              _section("Stress Level"),
              Text("Current: ${_stressLevel.round()} / 10", style: const TextStyle(fontSize: 14)),
              _stressSlider(),
              const SizedBox(height: 30),
              _section("Sleep Duration"),
              _sleepInput(),
              const SizedBox(height: 30),
              _section("Shortcut Notes"),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Choose options that fill up your day", style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 12),
              ...shortcutOptions.entries.map((e) => _shortcutSection(e.key, e.value)),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 10),
                  _nextPageButton(Icons.auto_awesome, "Notes NLP", () {
                    _navigateWithConfirmation(
                      context,
                      title: "Notes (AI NLP)",
                      description: "This page uses AI to summarize your notes. It is NOT certified for mental health guidance.",
                      builder: (ctx) => NotesScreen(selectedDate: _selectedDay),
                    );
                  }),

                  const SizedBox(width: 10),
                  _nextPageButton(Icons.book, "Journal", () {
                    _navigateWithConfirmation(
                      context,
                      title: "Journal (Templates)",
                      description: "This page provides structured journal templates to reflect on your day.",
                      builder: (ctx) => JournalScreen(selectedDate: _selectedDay),
                    );
                  }),

                  const SizedBox(width: 10),
                  _nextPageButton(Icons.videogame_asset, "Activities/Games",(){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActivitiesScreen(selectedDate: _selectedDay),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 30),

              if (_moodScore <= 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Please select a mood to enable saving",
                    style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _moodScore == 0 ? null : _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9575CD),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                      ),
                      child: const Text("Save Entry"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: !_hasEntryForSelectedDay ? null : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Entry"),
                            content: const Text("Are you sure you want to delete this entry?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                            ],
                          ),
                        );
                        if (confirm == true) _deleteEntry();
                      },
                      child: const Text("Delete Entry"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _calendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            eventLoader: (day) => _events[DateTime(day.year, day.month, day.day)] ?? [],
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(color: Color(0xFFC6B8DC), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(
                color: const Color(0xFF9071C7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF512DA8), width: 2),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (_, date, events) {
                if (events.isEmpty) return null;
                final mood = events.first as double;
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(color: _moodColor(mood), shape: BoxShape.circle),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _hasEntryForSelectedDay ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: _hasEntryForSelectedDay ? Colors.green : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  _hasEntryForSelectedDay ? "Entry saved for this day" : "No entry for this day",
                  style: TextStyle(color: _hasEntryForSelectedDay ? Colors.green : Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodScale() {
    final emojis = ['😄', '🙂', '😐', '🙁', '😖'];
    final labels = ['Great', 'Good', 'Okay', 'Bad', 'Awful'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (i) {
          final score = (i + 1).toDouble();
          final selected = _moodScore == score;
          return GestureDetector(
            onTap: () => setState(() => _moodScore = score),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: selected ? BoxDecoration(border: Border.all(color: _moodColor(score), width: 3), shape: BoxShape.circle) : null,
                  child: Opacity(opacity: selected ? 1 : 0.4, child: Text(emojis[i], style: const TextStyle(fontSize: 32))),
                ),
                Text(labels[i], style: const TextStyle(fontSize: 12))
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _stressSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Slider(
        value: _stressLevel,
        min: 0,
        max: 10,
        divisions: 10,
        activeColor: Colors.deepPurpleAccent,
        label: _stressLevel.round().toString(),
        onChanged: (v) => setState(() => _stressLevel = v),
      ),
    );
  }

  Widget _sleepInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<int>(
            value: _sleepHour,
            items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text("$i hrs"))),
            onChanged: (v) => setState(() => _sleepHour = v!),
          ),
          const SizedBox(width: 15),
          DropdownButton<int>(
            value: _sleepMinute,
            items: [0, 15, 30, 45].map((m) => DropdownMenuItem(value: m, child: Text("$m mins"))).toList(),
            onChanged: (v) => setState(() => _sleepMinute = v!),
          ),
        ],
      ),
    );
  }

  Widget _shortcutSection(String title, List<String> options) {
    final expanded = _expandedSections[title] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(color: Colors.deepPurple.shade100),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(25, 25),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => _addCustomKeyword(title),
                child: const Icon(Icons.add),
              ),

              const SizedBox(width: 6),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(25, 25),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => setState(() => _expandedSections[title] = !expanded),
                child: Icon( expanded ? Icons.expand_less : Icons.expand_more),
              ),
            ],
          ),
          if (expanded)
            Wrap(
              spacing: 8,
              children: options.map((opt) {
                final selected = selectedShortcuts[title]?.contains(opt) ?? false;
                return FilterChip(
                  label: Text(opt),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      final set = selectedShortcuts[title];
                      if (set == null) return;

                      v ? set.add(opt) : set.remove(opt);
                    });
                  },                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _jumpControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Jump to:   "),
          DropdownButton<int>(
            value: _focusedDay.month,
            menuMaxHeight: 250,
            items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(DateFormat.MMM().format(DateTime(0, i + 1))))),
            onChanged: (m) => setState(() => _focusedDay = DateTime(_focusedDay.year, m!, 1)),
          ),
          DropdownButton<int>(
            value: _focusedDay.year,
            menuMaxHeight: 250,
            items: List.generate(5, (i) => DropdownMenuItem(value: 2022 + i, child: Text("${2022 + i}"))),
            onChanged: (y) => setState(() => _focusedDay = DateTime(y!, _focusedDay.month, 1)),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF512DA8)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              _loadEntryForDay();
            },
            child: const Text("Today"),
          ),
        ],
      ),
    );
  }

  Widget _nextPageButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF9575CD).withValues(alpha:0.15),
            child: Icon(icon, color: const Color(0xFF9575CD), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Align(alignment: Alignment.centerLeft, child: Text(t, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600))),
  );

  Color _moodColor(double m) {
    if (m == 1) return Colors.green.shade800;
    if (m == 2) return Colors.lightGreen;
    if (m == 3) return Colors.yellow;
    if (m == 4) return Colors.orange;
    if (m == 5) return Colors.red;
    return Colors.grey;
  }

  String _badgeTitle(String id) {
    switch (id) {
      case 'going_strong':
        return 'Going Strong 💪';
      case 'consistent_creator':
        return 'Consistent Creator 🔥';
      case 'self_aware':
        return 'Self-Aware 🧠';
      default:
        return 'Achievement Unlocked';
    }
  }

  String _badgeDescription(String id) {
    switch (id) {
      case 'going_strong':
        return 'You logged 3 mood entries!';
      case 'consistent_creator':
        return '15 days of reflection — amazing!';
      case 'self_aware':
        return 'You noticed stress and tracked triggers.';
      default:
        return '';
    }
  }
}