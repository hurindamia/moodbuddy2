import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_theme.dart';
import '../../models/support_option.dart';
import '../../models/call_support_option.dart';
import 'self_check_screen.dart';
import 'result_history_screen.dart';
import 'support_detail_screen.dart';

class HotlineScreen extends StatefulWidget {
  const HotlineScreen({super.key});

  @override
  State<HotlineScreen> createState() => _HotlineScreenState();
}

class _HotlineScreenState extends State<HotlineScreen> {
  final user = FirebaseAuth.instance.currentUser;

  /* =========================
     SUPPORT OPTIONS (USM)
     EDIT DETAILS LATER
  ========================== */
  late SupportOption selectedSupport;

  final supportOptions = [
    SupportOption(
      title: 'USM Unit Kaunseling',
      description:
          'WHO:\n• University counsellors\n\n'
          'SUITABLE FOR:\n• Academic stress\n• Emotional concerns\n\n'
          'HOW TO GET HELP:\n• Appointment or walk-in\n\n'
          'CONTACT:\n• Phone: EDIT HERE\n• Email: EDIT HERE\n\n'
          'LOCATION:\n• EDIT BUILDING / ROOM\n\n'
          'BOOKING:\n• EDIT LINK',
    ),
    SupportOption(
      title: 'Pusat Sejahtera USM',
      description:
          'WHO:\n• Student wellbeing services\n\n'
          'SUPPORT:\n• Mental and physical wellbeing\n\n'
          'CONTACT & LOCATION:\n• EDIT HERE',
    ),
    SupportOption(
      title: 'School / Faculty Counselor',
      description:
          'WHO:\n• Faculty-based academic support\n\n'
          'SUITABLE FOR:\n• Study pressure\n• Adjustment issues\n\n'
          'CONTACT:\n• EDIT BASED ON FACULTY',
    ),
    SupportOption(
      title: 'Klinik Kesihatan near USM',
      description:
          'WHO:\n• Government healthcare\n\n'
          'SUITABLE FOR:\n• Mental & physical health\n\n'
          'HOW:\n• Walk-in\n\n'
          'LOCATION:\n• Near USM campus',
    ),
    SupportOption(
      title: 'Psychiatrist / Hospital near USM',
      description:
          'WHO:\n• Specialist mental health care\n\n'
          'HOW:\n• Referral or appointment\n\n'
          'SUITABLE FOR:\n• Persistent or severe distress',
    ),
  ];

  CallSupportOption? selectedCallOption;

final callSupportOptions = [
  CallSupportOption(
    name: 'MENTARI Mental Health Centre',
    phone: '15555', // EDIT IF NEEDED
  ),
  CallSupportOption(
    name: 'Befrienders (Emotional Support)',
    phone: '0376272929',
  ),
  CallSupportOption(
    name: 'Talian Kasih',
    phone: '15999',
  ),
  CallSupportOption(
    name: 'Emergency Services',
    phone: '999',
  ),
];

  @override
  void initState() {
    super.initState();
    selectedSupport = supportOptions.first;
  }

  /* =========================
     SAVE RESULT PER USER
  ========================== */
  Future<void> _saveResult(int score, String level) async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('self_check_results')
        .add({
      'score': score,
      'level': level,
      'date': Timestamp.now(),
    });
  }

  /* =========================
     SCORE INTERPRETATION
  ========================== */
  Map<String, dynamic> _interpretScore(int score) {
    if (score <= 6) {
      return {
        'label': 'LOW',
        'color': Colors.green,
        'details': [
          'Your responses suggest manageable emotional levels.',
          'Daily stress may be present but appears under control.',
          'Maintaining healthy routines is encouraged.',
        ],
      };
    } else if (score <= 12) {
      return {
        'label': 'MODERATE',
        'color': Colors.orange,
        'details': [
          'You may be experiencing noticeable emotional strain.',
          'Stress or worry could be affecting focus or motivation.',
          'Seeking support or talking to someone you trust may help.',
        ],
      };
    } else {
      return {
        'label': 'HIGH',
        'color': Colors.red,
        'details': [
          'Your responses suggest significant emotional distress.',
          'These feelings may interfere with daily life.',
          'Professional or campus support is strongly recommended.',
        ],
      };
    }
  }

  /* =========================
     PRE-TEST MESSAGE
  ========================== */
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
                final interpretation = _interpretScore(result);
                await _saveResult(result, interpretation['label']);
                _showResultDialog(result, interpretation);
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

    /* =========================
     CALL SUPPORT HELPER
  ========================== */
  void _callNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    await launchUrl(uri);
  }


  /* =========================
     RESULT DIALOG
  ========================== */
  void _showResultDialog(int score, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Your Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${result['label']} : $score',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: result['color'],
              ),
            ),
            const SizedBox(height: 12),
            ...result['details']
                .map<Widget>((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $d'),
                    ))
                .toList(),
            const SizedBox(height: 10),
            const Text(
              'This result is not a diagnosis.',
              style: TextStyle(fontSize: 12),
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
     OFFICIAL DASS WEBSITE
  ========================== */
  void _openOfficialDASS() async {
    await launchUrl(
      Uri.parse('https://mits.moh.gov.my/Modules/Patient/public-dass/'),
      mode: LaunchMode.externalApplication,
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
          /* INTRO */
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 151, 191, 231),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'This section helps USM students reflect on emotional wellbeing '
              'and find appropriate campus or healthcare support.',
              style: TextStyle(color: Color.fromARGB(255, 6, 49, 122)),
            ),
          ),

          const SizedBox(height: 28),

          /* SELF CHECK */
          const Text(
            'MoodBuddy Self-Check',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            onPressed: _showPreTestDialog,
            child: const Text(
              'Start In-App Self-Check',
              style: TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Select support option',
            ),
          ),

const SizedBox(height: 24),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SupportDetailScreen(option: selectedSupport),
                ),
              );
            },
            child: const Text(
              'View Support Details',
              style: TextStyle(color: Colors.white),
            ),
          ),


        const SizedBox(height: 36),
        /* =========================
          CALL FOR IMMEDIATE CONCERN
        ========================== */
        const Text(
          'Who to Call for Immediate Concern',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'If you are worried about your thoughts or someone’s safety, '
          'consider reaching out to one of the following services.',
          style: TextStyle(fontSize: 14),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<CallSupportOption>(
          value: selectedCallOption,
          decoration: const InputDecoration(
            labelText: 'Select a support line',
            border: OutlineInputBorder(),
          ),
          items: callSupportOptions
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => selectedCallOption = value);

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
