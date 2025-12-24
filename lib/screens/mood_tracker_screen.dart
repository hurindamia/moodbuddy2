import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/foundation.dart'; // Required for setEquals
import 'notes_screen.dart';
import 'journal_screen.dart';
import 'activities_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  // === STATE VARIABLES ===
  double _moodScore = 0;
  double _stressLevel = 1;
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
  double _initialStress = 1;
  int _initialSleepHour = 0;
  int _initialSleepMinute = 0;
  Map<String, Set<String>> _initialShortcuts = {};

  @override
  void initState() {
    super.initState();
    for (final k in shortcutOptions.keys) {
      _expandedSections[k] = true;
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
          _stressLevel = (data['stressLevel'] ?? 1).toDouble();
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
          _moodScore = 0;
          _stressLevel = 1;
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
      });
    }
  }

  Future<void> _saveEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final id = DateFormat('yyyy-MM-dd').format(_selectedDay);

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
    });

    await _loadAllEntries();
    await _loadEntryForDay();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mood entry saved successfully"), behavior: SnackBarBehavior.floating),
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

    final data = doc.data()!;
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
        _stressLevel == 1 &&
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

  // ================= BUILD METHOD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mood Tracker", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color(0xFF9575CD),
      ),
      body: SingleChildScrollView(
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
                _nextPageButton(Icons.auto_awesome, "Notes", (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotesScreen(selectedDate: _selectedDay),
                    ),
                  );
                }),
                _nextPageButton(Icons.book, "Journal", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JournalScreen(selectedDate: _selectedDay),
                    ),
                  );
                }),

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
    );
  }

  // ================= COMPONENTS =================

  Widget _calendar() {
    return Column(
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
    );
  }

  Widget _moodScale() {
    final emojis = ['😄', '🙂', '😐', '🙁', '😖'];
    final labels = ['Great', 'Good', 'Okay', 'Bad', 'Awful'];
    return Row(
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
    );
  }

  Widget _stressSlider() {
    return Slider(
      value: _stressLevel,
      min: 1,
      max: 10,
      divisions: 9,
      activeColor: Colors.deepPurpleAccent,
      label: _stressLevel.round().toString(),
      onChanged: (v) => setState(() => _stressLevel = v),
    );
  }

  Widget _sleepInput() {
    return Row(
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
    );
  }

  Widget _shortcutSection(String title, List<String> options) {
    final expanded = _expandedSections[title] ?? true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.deepPurple.shade100), borderRadius: BorderRadius.circular(12)),
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
                final selected = selectedShortcuts[title]!.contains(opt);
                return FilterChip(
                  label: Text(opt),
                  selected: selected,
                  onSelected: (v) => setState(() => v ? selectedShortcuts[title]!.add(opt) : selectedShortcuts[title]!.remove(opt)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _jumpControl() {
    return Row(
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
}