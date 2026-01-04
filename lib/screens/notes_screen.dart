import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'resource_library_screen.dart';

class NotesScreen extends StatefulWidget {
  final DateTime selectedDate;
  const NotesScreen({super.key, required this.selectedDate});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String _sentiment = "Write something to analyze...";
  String _emoji = "✍️";

  Future<void> _analyzeAndSave() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": _controller.text}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      final sentiment = data['label'];

      setState(() {
        _sentiment = sentiment;
        _emoji = _getEmoji(sentiment);
      });

      // Navigate to Resource Library after analysis
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ResourceLibraryScreen(),
        ),
      );


      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final dateId = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

      // Save note as subcollection document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mood_entries')
          .doc(dateId)
          .collection('notes')
          .add({
        'content': _controller.text.trim(),
        'sentiment': sentiment,
        'score': data['score'],
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update parent day summary
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mood_entries')
          .doc(dateId)
          .set({
        'hasNotes': true,
        'last_note_sentiment': sentiment,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (sentiment == "NEGATIVE" && mounted) {
        _showSupportDialog();
      }

    } catch (e) {
      debugPrint("🔥 Notes save error: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
    finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You're not alone"),
        content: const Text(
            "Your entry seems emotionally heavy. Would you like to explore support options?"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/hotline');
            },
            child: const Text("Get Support"),
          ),
        ],
      ),
    );
  }

  String _getEmoji(String label) {
    if (label == "POSITIVE") return "🌟 Positive";
    if (label == "NEGATIVE") return "😟 Distressed";
    return "😐 Neutral";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Notes", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF9575CD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: "Write your thoughts freely...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(_sentiment, style: GoogleFonts.poppins()),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _analyzeAndSave,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Analyze & Save"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
