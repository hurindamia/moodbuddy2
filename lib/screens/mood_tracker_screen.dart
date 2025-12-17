import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activities_menu_screen.dart';
import 'meditation_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  double _moodScore = 3;
  double _stressLevel = 5;
  double _sleepHours = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Check-in', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF9575CD),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyCalendar(),
            const SizedBox(height: 30),
            _buildSectionTitle("How are you feeling? (Mood)"),
            _buildMoodScale(),
            const SizedBox(height: 25),
            _buildSectionTitle("Current Stress Level (1-10)"),
            _buildStressScale(),
            const SizedBox(height: 25),
            _buildSectionTitle("Sleep Duration (Hours)"),
            _buildSleepInput(),
            const SizedBox(height: 30),
            _buildSectionTitle("Shortcuts"),
            _buildShortcuts(),
            const SizedBox(height: 30),

            // --- QUICK ACTIONS SECTION ---
            _buildQuickActionButtons(),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9575CD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Save Entry", style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _quickButton(Icons.auto_awesome, "AI Notes", () {
          // Add AI Notes Navigation here
        }),
        _quickButton(Icons.book, "Journal", () {
          // Add Journal Navigation here
        }),
        _quickButton(Icons.videogame_asset, "Games", () {
          // NAVIGATE TO GAMES MENU
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActivitiesMenuScreen()),
          );
        }),
      ],
    );
  }

  Widget _quickButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF9575CD).withOpacity(0.2),
            child: Icon(icon, color: const Color(0xFF9575CD)),
          ),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }

  // --- REUSE YOUR EXISTING BUILDERS FOR CALENDAR, SCALES, ETC ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildWeeklyCalendar() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dates = ['15', '16', '17/12', '18', '19', '20', '21'];
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          bool isToday = index == 2;
          return Column(
            children: [
              Text(days[index], style: TextStyle(color: index == 6 ? Colors.red : Colors.black54)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: isToday ? const Color(0xFF9575CD) : Colors.transparent),
                child: Text(dates[index], style: TextStyle(color: isToday ? Colors.white : Colors.black, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMoodScale() {
    List<String> emojis = ['😢', '😟', '😐', '😊', '😁'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => setState(() => _moodScore = (index + 1).toDouble()),
          child: Opacity(
            opacity: _moodScore == index + 1 ? 1.0 : 0.3,
            child: Text(emojis[index], style: const TextStyle(fontSize: 40)),
          ),
        );
      }),
    );
  }

  Widget _buildStressScale() {
    return Slider(
      value: _stressLevel,
      min: 1, max: 10, divisions: 9,
      activeColor: Colors.orange,
      onChanged: (value) => setState(() => _stressLevel = value),
    );
  }

  Widget _buildSleepInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: () => setState(() => _sleepHours--), icon: const Icon(Icons.remove_circle_outline)),
        Text("${_sleepHours.toStringAsFixed(1)} hrs", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => setState(() => _sleepHours++), icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }

  Widget _buildShortcuts() {
    return Wrap(
      spacing: 10,
      children: [
        ActionChip(label: const Text("Reading"), onPressed: () {}),
        ActionChip(label: const Text("Sports"), onPressed: () {}),
        ActionChip(label: const Text("Gaming"), onPressed: () {}),
      ],
    );
  }
}