import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/activity_service.dart';

class JournalScreen extends StatefulWidget {
  final DateTime selectedDate;

  const JournalScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedTemplate;

  final Map<String, String> templates = {
    "Gratitude Entry": "What are 3 things you’re grateful for today?",
    "Self-Reflection": "What went well? What was challenging?",
    "To-Do List": "What do you want to accomplish tomorrow?",
  };

  Future<void> _saveJournal() async {
    if (_controller.text.trim().isEmpty) return;

    await ActivityService.saveActivity(
      date: widget.selectedDate,
      activityData: {
        'journal': FieldValue.arrayUnion([
          {
            'template': _selectedTemplate,
            'content': _controller.text.trim(),
            'timestamp': DateTime.now(),
          }
        ]),
      },
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<bool?> _confirmReplaceOrAdd() async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Journal already has content"),
        content: const Text(
            "Do you want to replace the current writing or add this template below?"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Add"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Replace"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Text(
          "Journal",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveJournal,
            child: Text(
              "Save",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9575CD),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: templates.keys.map((t) {
                return ChoiceChip(
                  label: Text(t),
                  selected: _selectedTemplate == t,
                  onSelected: (_) async {
                    bool hasText = _controller.text.trim().isNotEmpty;

                    if (hasText) {
                      final replace = await _confirmReplaceOrAdd();
                      if (replace == true) {
                        _controller.text = templates[t]!;
                      } else if (replace == false) {
                        _controller.text += "\n\n${templates[t]!}";
                      }
                    } else {
                      _controller.text = templates[t]!;
                    }

                    setState(() {
                      _selectedTemplate = t;
                    });
                  },

                  selectedColor: const Color(0xFF9575CD),
                  labelStyle: TextStyle(
                    color: _selectedTemplate == t ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: "Write your thoughts here...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
