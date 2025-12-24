import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';

class NotesScreen extends StatefulWidget {
  final DateTime selectedDate;
  const NotesScreen({super.key, required this.selectedDate});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnalyzing = false;
  String _sentiment = "Write something to analyze...";
  String _sentimentEmoji = "✍️";

  // --- HUGGING FACE API SETUP ---
  final String _apiKey = dotenv.env['HF_API_KEY']!;
  final String _modelUrl = "https://api-inference.huggingface.co/models/distilbert-base-uncased-finetuned-sst-2-english";

  Future<void> _analyzeAndSave() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // 1. Call Hugging Face API
      final request = http.post(
        Uri.parse(_modelUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inputs": _controller.text}),
      );

      final response = await request.timeout(
        const Duration(seconds: 25),
      );

      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded.containsKey('error')) {
        throw Exception("Model is loading");
      }

      final List<dynamic> data = decoded;
      List sentiments = data[0];
      sentiments.sort((a, b) => b['score'].compareTo(a['score']));
      var topSentiment = sentiments.first;

      setState(() {
        _sentiment = topSentiment['label'].toUpperCase();
        _sentimentEmoji = _getEmoji(_sentiment);
      });

      // Save to Firebase
      String dateId = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      await FirebaseFirestore.instance
          .collection('mood_entries')
          .doc(dateId)
          .set({
        'notes': FieldValue.arrayUnion([
          {
            'content': _controller.text.trim(),
            'sentiment': _sentiment,
            'sentiment_score': topSentiment['score'],
            'created_at': FieldValue.serverTimestamp(),
          }
        ]),
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note & AI analysis saved")),
      );

      // NEGATIVE → Suggest hotline
      if (_sentiment.contains("NEGATIVE")) {
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("You're not alone"),
              content: const Text(
                "If you're feeling overwhelmed, support is available.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Maybe Later"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/hotline');
                  },
                  child: const Text("View Support"),
                ),
              ],
            ),
          );
        });
      }

    } catch (e) {
      // ⭐ THIS IS THE UX FALLBACK ⭐
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "AI is warming up or network is slow. Please try again in a moment.",
          ),
        ),
      );

    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  String _getEmoji(String label) {
    if (label.contains("POSITIVE")) return "🌟 Happy";
    if (label.contains("NEGATIVE")) return "😟 Distressed";
    return "😐 Neutral";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Journal", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF9575CD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Reflecting on ${DateFormat('MMMM dd, yyyy').format(widget.selectedDate)}",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "How was your day? Write freely...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AI Sentiment Result Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF9575CD).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text(_sentimentEmoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 15),
                  Text(
                    _sentiment.contains("NEGATIVE")
                        ? "It sounds like you're going through something difficult."
                        : _sentiment.contains("POSITIVE")
                        ? "You seem to be in a positive headspace today."
                        : "Your emotions seem balanced today.",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeAndSave,
                icon: _isAnalyzing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isAnalyzing ? "Analyzing..." : "Analyze & Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9575CD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}