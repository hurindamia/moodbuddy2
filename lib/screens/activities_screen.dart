import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../games/breathing_screen.dart';
import '../games/meditation_screen.dart';
import '../games/feeling_wheel_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  final DateTime selectedDate;
  const ActivitiesScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background to match your professional theme
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9575CD), // Deep Purple
              Color(0xFFF3E5F5), // Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Self-Care Activities",
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      // REMOVED 'const' TO FIX THE ERROR
                      _activityBox(context, "Breathing", "4-7-8 Technique", Icons.air, Colors.white, BreathingScreen(selectedDate: selectedDate,)),
                      const SizedBox(height: 20),
                      _activityBox(context, "Meditate", "Relaxation Timer", Icons.self_improvement, Colors.white, const MeditationScreen()),
                      const SizedBox(height: 20),
                      _activityBox(context, "Feeling Wheel", "Emotion Explorer", Icons.color_lens, Colors.white, const FeelingWheelScreen()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityBox(BuildContext context, String title, String sub, IconData icon, Color color, Widget? target) {
    return InkWell(
      onTap: () {
        if (target != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => target));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Feeling Wheel coming soon!")),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.9),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 15,
                offset: const Offset(0, 5)
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF9575CD).withValues(alpha:0.2),
              child: Icon(icon, size: 30, color: const Color(0xFF9575CD)),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(sub, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}