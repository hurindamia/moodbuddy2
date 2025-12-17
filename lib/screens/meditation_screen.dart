import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  Timer? _timer;
  int _targetSeconds = 600;
  int _currentSeconds = 600;
  bool _isRunning = false;
  final List<int> _timeOptions = [5, 10, 20, 30, 40, 50, 60, 70, 80];

  void _startTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentSeconds > 0) _currentSeconds--;
          else { _timer?.cancel(); _isRunning = false; }
        });
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1.0 - (_currentSeconds / _targetSeconds);
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text("Meditation", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Done", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF9575CD))),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 220, height: 220, child: CircularProgressIndicator(value: progress, strokeWidth: 10, backgroundColor: Colors.white, valueColor: const AlwaysStoppedAnimation(Color(0xFF9575CD)))),
              Text("${(_currentSeconds ~/ 60).toString().padLeft(2, '0')}:${(_currentSeconds % 60).toString().padLeft(2, '0')}", style: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          if (!_isRunning) _buildGrid(),
          const SizedBox(height: 40),
          CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFF9575CD),
              child: IconButton(icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 35), onPressed: _startTimer)
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15),
        itemCount: _timeOptions.length,
        itemBuilder: (context, index) {
          int mins = _timeOptions[index];
          bool isSelected = (_targetSeconds / 60).round() == mins;
          return GestureDetector(
            onTap: () => setState(() { _targetSeconds = mins * 60; _currentSeconds = _targetSeconds; }),
            child: Container(
              decoration: BoxDecoration(color: isSelected ? const Color(0xFF9575CD) : Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Center(child: Text("$mins", style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
            ),
          );
        },
      ),
    );
  }
}