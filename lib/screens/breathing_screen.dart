import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});
  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instruction = "Inhale";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _startCycle();
  }

  void _startCycle() async {
    while (mounted) {
      if (!mounted) return;
      setState(() => _instruction = "Inhale (Nose)");
      await _controller.animateTo(1.0, duration: const Duration(seconds: 4), curve: Curves.easeInOut);
      if (!mounted) return;
      setState(() => _instruction = "Hold");
      await Future.delayed(const Duration(seconds: 7));
      if (!mounted) return;
      setState(() => _instruction = "Exhale (Mouth)");
      await _controller.animateTo(0.0, duration: const Duration(seconds: 8), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text("Breathing", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Done", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF9575CD))),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_instruction, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF7E57C2))),
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 150 + (130 * _controller.value),
                  height: 150 + (130 * _controller.value),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF9575CD).withValues(alpha:0.3), border: Border.all(color: const Color(0xFF9575CD), width: 3)),
                  child: const Icon(Icons.air, size: 40, color: Color(0xFF9575CD)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}