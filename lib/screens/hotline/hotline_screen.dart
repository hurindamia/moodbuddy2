import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodbuddy2/screens/hotline/support_detail_screen.dart';
import 'package:moodbuddy2/widgets/psychologist_card.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_theme.dart';
import '../../models/support_option.dart';
import '../../models/call_support_option.dart';
import '../../models/self_check_question.dart';
import '../../models/self_check_result.dart';
import '../../models/clinic_card.dart';

import 'self_check_screen.dart';
import 'result_history_screen.dart';
// ignore: duplicate_import
import 'support_detail_screen.dart';

class HotlineScreen extends StatefulWidget {
  const HotlineScreen({super.key});

  @override
  State<HotlineScreen> createState() => _HotlineScreenState();
}

class _HotlineScreenState extends State<HotlineScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late SupportOption selectedSupport;
  CallSupportOption? selectedCallOption;
  String username = '';

  final supportOptions = [
    SupportOption(
      title: 'Unit Kaunseling USM',
      description: 'Unit Kaunseling USM provides professional counselling and '
          'psychological services to support students\' emotional wellbeing, '
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
      ],
    ),
    SupportOption(
      title: 'Pusat Sejahtera USM',
      description:
      'Pusat Sejahtera USM is the primary healthcare centre for students '
          'and staff at Universiti Sains Malaysia.\n\n'
          'It provides medical and wellbeing services including mental health '
          'support, basic medical consultations, and referrals to specialist care.\n\n'
          'Students may visit Pusat Sejahtera for concerns such as stress-related '
          'health issues, emotional wellbeing, sleep problems, or when a medical '
          'referral is required.',
      locationQuery: 'Pusat Sejahtera USM',
      address: 'Pusat Sejahtera USM\n'
          'Universiti Sains Malaysia\n'
          'Kampus Induk, 11800 Gelugor, Pulau Pinang',
      website: 'https://pusatsejahtera.usm.my', // EDIT IF NEEDED
      imagePath: 'assets/images/ps_usm.png',
      psychologists: null, // Medical-based service (not counsellor list)
    ),
    SupportOption(
      title: 'Mental Health Services near USM',
      description: 'Specialist mental health services near USM.',
      locationQuery: 'psychiatrist near Universiti Sains Malaysia',
      imagePath: 'assets/images/kk.jpg',
      showWebsiteButton: false,
      clinics: [
        const ClinicCard(
          name: 'Hospital Pulau Pinang – Psychiatry Department',
          address: 'Jalan Residensi, 10990 George Town, Penang',
          phone: '+604-2225333',
          locationQuery: 'Hospital Pulau Pinang Psychiatry',
          imagePath: 'assets/images/hpp.jpg',
          website: 'https://hospulaupinang.moh.gov.my',
        ),
        const ClinicCard(
          name: 'Klinik Kesihatan Sungai Dua',
          address:
          'Jalan Pinang, Kampung Dua Bukit, 11700 Gelugor, Pulau Pinang',
          phone: '+604-642 2201',
          locationQuery: 'Klinik Kesihatan Sungai Dua',
          imagePath: 'assets/images/kk.jpg',
        ),
        const ClinicCard(
          name: 'Mintygreen Psychological & Counseling Services',
          address:
          '1-1-9, Imperial Grande, Persiaran Relau, Kampung Darat, 11900 Bayan Lepas, Pulau Pinang',
          phone: '+60 18-205 2528',
          locationQuery: 'Mintygreen Bayan Lepas',
          imagePath: 'assets/images/mintygreen.jpg',
        ),
        const ClinicCard(
          name: 'Blue Mind Specialist Clinic (Psychiatry)',
          address:
          'B-12, 1, Lorong Bayan Indah 3, Bay Avenue, 11900 Bayan Lepas, Pulau Pinang',
          phone: '+6011-5657 6877',
          locationQuery: 'Blue Mind Specialist Clinic (Psychiatry)',
          imagePath: 'assets/images/blue_mind.jpg',
        ),
        const ClinicCard(
          name: 'Carpe Diem Counseling & Consulting Centre',
          address:
          '723-J-1, Vanda Business Park, Jalan Sungai Dua, 11700 Gelugor, Penang, Jalan Sungai Dua, 11700 Gelugor, Penang',
          phone: '+6012-281 0045',
          locationQuery: 'Carpe Diem Counseling & Consulting 卡比典心灵成长工作室',
          imagePath: 'assets/images/carpe.jpg',
        ),
        const ClinicCard(
          name: 'Persatuan Minda DHome',
          address:
          '66, Lintang Bukit Jambul, Bukit Jambul, 11900 Bayan Lepas, Pulau Pinang',
          phone: '+604-291 0111',
          locationQuery: 'Persatuan Minda DHome',
          imagePath: 'assets/images/dhome.jpg',
        ),
        const ClinicCard(
          name: 'MENTARI Penang',
          address: 'Jalan Perak, George Town, Penang',
          phone: '+604-2886233',
          locationQuery: 'MENTARI Penang',
          imagePath: 'assets/images/mentari.jpg',
        ),
      ],
    ),
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
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        username = doc['fullName'] ?? '';
      });
    }
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
      return {
        'label': 'LOW',
        'color': Colors.green,
        'message': [
          'Your responses suggest that your emotional wellbeing is currently within a manageable range.',
          'You may still experience occasional stress or low mood, which is a normal part of daily life.',
          'Continue practicing healthy routines such as adequate rest, balanced study schedules, and social connection.',
          'It may be helpful to check in with yourself regularly and use this self-check again when needed.'
        ],
      };
    } else if (percentage <= 50) {
      return {
        'label': 'MILD–MODERATE',
        'color': const Color.fromARGB(255, 205, 138, 4),
        'message': [
          'Your responses suggest that you may be experiencing noticeable emotional strain at times.',
          'You might feel stressed, worried, or less motivated more frequently than usual.',
          'Consider taking short breaks, managing academic workload, and talking to someone you trust.',
          'If these feelings persist, seeking campus support such as counselling services may be helpful.',
        ],
      };
    } else if (percentage <= 75) {
      return {
        'label': 'MODERATE–HIGH',
        'color': Colors.orange,
        'message': [
          'Your responses suggest a higher level of emotional difficulty that may be affecting your daily life.',
          'You may feel overwhelmed, anxious, or emotionally tired more often.',
          'It is recommended to reach out for support, such as a university counsellor or student wellbeing services.',
          'Early support can help prevent these feelings from becoming more difficult to manage.',
        ],
      };
    } else {
      return {
        'label': 'HIGH',
        'color': Colors.red,
        'message': [
          'Your responses suggest significant emotional distress at this time.',
          'These feelings may be having a strong impact on your wellbeing, focus, or daily functioning.',
          'You are strongly encouraged to seek support from professional or campus mental health services.',
          'If you feel unsafe or overwhelmed, please reach out to emergency or crisis support immediately.',
        ],
      };
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ LOGO
            Image.asset(
              'assets/images/moodbuddy_logo3.png',
              height: 100,
            ),

            const Text(
              'This self-check helps you reflect on how you have been feeling recently.\n\n'
                  'It is not a medical diagnosis.\n\n'
                  'You may stop at any time.',
            ),
          ],
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

                  if (!mounted) return;
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Your Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LABEL + SCORE
            Text(
              '${result['label']} : $score',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: result['color'],
              ),
            ),

            const SizedBox(height: 12),

            // SUPPORTIVE MESSAGES
            ...List<Widget>.from(
              (result['message'] as List<String>).map(
                    (msg) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• $msg',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // DISCLAIMER
            const Text(
              'This self-check is not a medical diagnosis.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
          backgroundColor: const Color(0xFF9575CD)
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background1.png'),
            fit: BoxFit.cover,
            opacity: 0.8,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            /* IMAGE */
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/moodbuddy12.png',
                width: 250,
                fit: BoxFit.fitWidth,
              ),
            ),
            Text(
              'We\'re glad you\'re here.\n'
                  'Take a moment to check in with yourself — support is always available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade700,
              ),
            ),

            /* BLUE INFO BOX */
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'This section helps USM students reflect on their emotional wellbeing '
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9575CD),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _openOfficialDASS,
              child: const Text(
                'Take Official DASS Test (External)',
                style: TextStyle(color: Colors.white),
              ),
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
                backgroundColor: const Color.fromARGB(255, 111, 88, 153),
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
              initialValue: selectedSupport,
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
              initialValue: selectedCallOption,
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
      ),
    );
  }
}