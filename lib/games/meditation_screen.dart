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

  // Updated list: 5 to 50 only to save space and fix stripes
  final List<int> _timeOptions = [5, 10, 15, 20, 25, 30, 40, 50];

  void _startTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentSeconds > 0) {
            _currentSeconds--;
          } else {
            _timer?.cancel();
            _isRunning = false;
          }
        });
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = 1.0 - (_currentSeconds / _targetSeconds);

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text("Meditation",
            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Centers the title in the bar
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Done",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF9575CD))),
          ),
        ],
      ),
      // This Center + Container(width: double.infinity) forces the Column to be centered
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
          children: [
            // 1. TIMER CIRCLE
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF9575CD))
                    )
                ),
                Text(
                    "${(_currentSeconds ~/ 60).toString().padLeft(2, '0')}:${(_currentSeconds % 60).toString().padLeft(2, '0')}",
                    style: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold)
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 2. TIME GRID (Hidden when running)
            if (!_isRunning) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 columns makes it much shorter
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2
                  ),
                  itemCount: _timeOptions.length,
                  itemBuilder: (context, index) {
                    int mins = _timeOptions[index];
                    bool isSelected = (_targetSeconds / 60).round() == mins;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _targetSeconds = mins * 60;
                        _currentSeconds = _targetSeconds;
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF9575CD) : Colors.white,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Center(
                            child: Text("$mins",
                                style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold
                                )
                            )
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],

            // 3. PLAY/PAUSE BUTTON
            CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF9575CD),
                child: IconButton(
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 35),
                    onPressed: _startTimer
                )
            ),
          ],
        ),
      ),
    );
  }
}