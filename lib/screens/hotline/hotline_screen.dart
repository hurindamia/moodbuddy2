import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodbuddy2/widgets/psychologist_card.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_theme.dart';
import '../../models/support_option.dart';
import '../../models/call_support_option.dart';
import '../../models/self_check_question.dart';
import '../../models/self_check_result.dart';

import 'self_check_screen.dart';
import 'result_history_screen.dart';
import 'support_detail_screen.dart';

class HotlineScreen extends StatefulWidget {
  const HotlineScreen({super.key});

  @override
  State<HotlineScreen> createState() => _HotlineScreenState();
}

class _HotlineScreenState extends State<HotlineScreen> {
  late SupportOption selectedSupport;
  CallSupportOption? selectedCallOption;

  final supportOptions = [
    SupportOption(
      title: 'Unit Kaunseling USM',
      description: 'Unit Kaunseling USM provides professional counselling and '
          'psychological services to support students’ emotional wellbeing, '
          'academic adjustment, and personal development.\n\n'
          'Students may seek help for stress, anxiety, academic pressure, '
          'personal concerns, or adjustment to university life.',
      locationQuery: 'Unit Kaunseling USM',
      website: 'https://hepa.usm.my/index.php/servis/kaunseling', // EDIT LATER
      imagePath: 'assets/images/unit_kaunseling_usm.jpg',
      psychologists: [
        const PsychologistCard(
          name: 'ENCIK AHMAD ANWAR BIN OMAR',
          position: 'Pegawai Psikologi',
          department: 'BHEPA, Kampus Induk',
          phone: '3411',
          email: 'ahmad_anwar@usm.my',
          imagePath: 'assets/images/psychologists/anwar.jpg',
        ),
        const PsychologistCard(
          name: 'PUAN ANIS NATASHA BINTI ZULKIFLI',
          position: 'Pegawai Psikologi',
          department: 'BHEPA, Kampus Induk',
          phone: '3409',
          email: 'anisnatasha@usm.my',
          imagePath: 'assets/images/psychologists/anis.jpg',
        ),
        const PsychologistCard(
          name: 'PUAN FAUZIAH BINTI ABDULLAH',
          position: 'Pegawai Psikologi',
          department: 'BHEPA, Kampus Induk',
          phone: '5835',
          email: 'afauziah@usm.my',
          imagePath: 'assets/images/psychologists/fauziah.jpg',
        ),
        const PsychologistCard(
          name: 'ENCIK MOHAMMAD ZAFRAN BIN MOHD RAFAAI',
          position: 'Pegawai Psikologi',
          department: 'BHEPA, Kampus Induk',
          phone: '3459',
          email: 'zafranrafaai@usm.my',
          imagePath: 'assets/images/psychologists/anis.jpg',
        ),

        // ADD MORE FROM DIRECTORY LATER
      ],
    ),
    SupportOption(
      title: 'Pusat Sejahtera USM',
      description: 'Student wellbeing and health services.',
      locationQuery: 'Pusat Sejahtera USM',
    ),
    SupportOption(
      title: 'School / Faculty Counselor',
      description: 'Faculty-based counselling and academic support.',
      locationQuery: 'Universiti Sains Malaysia',
    ),
    SupportOption(
        title: 'Psychiatrist near USM',
        description: 'EDIT DETAILS HERE',
        locationQuery: ''),
    SupportOption(
        title: 'Hospital/Klinik Kesihatan near USM',
        description: 'EDIT DETAILS HERE',
        locationQuery: ''),
  ];

  final callSupportOptions = [
    CallSupportOption(name: 'MENTARI Mental Health Centre', phone: '15555'),
    CallSupportOption(name: 'Befrienders', phone: '0376272929'),
    CallSupportOption(name: 'Talian Kasih', phone: '15999'),
    CallSupportOption(name: 'Emergency Services', phone: '999'),
  ];

  @override
  void initState() {
    super.initState();
    selectedSupport = supportOptions.first;
  }

  /* =========================
     FIREBASE SAVE
  ========================== */
  Future<void> saveResult(
    int totalScore,
    double percentage,
    Map<String, int> categoryScores,
  ) async {
    final user = FirebaseAuth.instance.currentUser!;
    final result = SelfCheckResult(
      totalScore: totalScore,
      percentage: percentage,
      categoryScores: categoryScores,
      date: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('self_check_results')
        .add(result.toFirestore());
  }

  Map<String, int> _calculateCategoryScores(
    List<SelfCheckQuestion> questions,
  ) {
    final scores = {'stress': 0, 'anxiety': 0, 'mood': 0};
    for (final q in questions) {
      scores[q.category.name] = scores[q.category.name]! + q.score;
    }
    return scores;
  }

  Map<String, dynamic> _interpretScore(double percentage) {
    if (percentage <= 25) {
      return {'label': 'LOW', 'color': Colors.green};
    } else if (percentage <= 50) {
      return {'label': 'MILD–MODERATE', 'color': Colors.yellow};
    } else if (percentage <= 75) {
      return {'label': 'MODERATE–HIGH', 'color': Colors.orange};
    } else {
      return {'label': 'HIGH', 'color': Colors.red};
    }
  }

  void _callNumber(String phone) async {
    await launchUrl(Uri.parse('tel:$phone'));
  }

  void _openOfficialDASS() async {
    await launchUrl(
      Uri.parse('https://mits.moh.gov.my/Modules/Patient/public-dass/'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _showPreTestDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Before You Begin'),
        content: const Text(
          'This self-check helps you reflect on how you have been feeling recently.\n\n'
          'It is not a medical diagnosis.\n\n'
          'You may stop at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            onPressed: () async {
              Navigator.pop(context);

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SelfCheckScreen(),
                ),
              );

              if (result != null) {
                final interpretation = _interpretScore(result['percentage']);

                await saveResult(
                  result['totalScore'],
                  result['percentage'],
                  _calculateCategoryScores(result['questions']),
                );

                if (interpretation['label'] == 'HIGH') {
                  setState(() {
                    selectedSupport = supportOptions.first; // Unit Kaunseling
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'We recommend contacting Unit Kaunseling USM for professional support.',
                      ),
                    ),
                  );
                }

                _showResultDialog(
                  result['totalScore'],
                  interpretation,
                );
              }
            },
            child: const Text(
              'Start Self-Check',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(int score, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Your Result'),
        content: Text(
          '${result['label']} : $score',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: result['color'],
          ),
        ),
      ),
    );
  }

  /* =========================
     UI
  ========================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotline & Self-Check'),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /* IMAGE */
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/moodbuddy_white.jpg',
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          /* BLUE INFO BOX */
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'This module helps USM students reflect on their emotional wellbeing '
              'and connect with appropriate campus and professional support.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 30),

          /* SELF CHECK */
          const Text(
            'MoodBuddy Self-Check',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _showPreTestDialog,
            child: const Text(
              'Start In-App Self-Check',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _openOfficialDASS,
            child: const Text('Take Official DASS Test (External)'),
          ),
          const SizedBox(height: 30),

          /* HISTORY */
          ElevatedButton.icon(
            icon: const Icon(Icons.history, color: Colors.white),
            label: const Text(
              'View My Past Results',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ResultHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 30),

          /* SUPPORT */
          const Text(
            'Find Student Support',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<SupportOption>(
            value: selectedSupport,
            decoration: const InputDecoration(
              labelText: 'Select support option',
              border: OutlineInputBorder(),
            ),
            items: supportOptions
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.title),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => selectedSupport = val!);
            },
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SupportDetailScreen(option: selectedSupport),
                ),
              );
            },
            child: const Text(
              'View Support Details',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),

          /* CALL SUPPORT */
          const Text(
            'Who to Call for Immediate Concern',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<CallSupportOption>(
            value: selectedCallOption,
            decoration: const InputDecoration(
              labelText: 'Select a support line',
              border: OutlineInputBorder(),
            ),
            items: callSupportOptions
                .map(
                  (o) => DropdownMenuItem(
                    value: o,
                    child: Text(o.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _callNumber(value.phone);
              }
            },
          ),
        ],
      ),
    );
  }
}
