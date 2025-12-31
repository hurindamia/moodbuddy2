import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';

class HotlineScreen extends StatefulWidget {
  const HotlineScreen({super.key});

  @override
  State<HotlineScreen> createState() => _HotlineScreenState();
}

class _HotlineScreenState extends State<HotlineScreen> {
  final TextEditingController scoreCtrl = TextEditingController();
  String selectedState = 'Kuala Lumpur';

  /* =========================
     FIREBASE SAVE
  ========================== */
  Future<void> _saveResult(int score, String level) async {
    await FirebaseFirestore.instance.collection('dass_results').add({
      'score': score,
      'level': level,
      'createdAt': Timestamp.now(),
    });
  }

  /* =========================
     OPEN DASS WEBSITE
  ========================== */
  void _openDASS() async {
    await launchUrl(
      Uri.parse('https://mits.moh.gov.my/Modules/Patient/public-dass/'),
      mode: LaunchMode.externalApplication,
    );
  }

  /* =========================
     GOOGLE MAPS (STATE FILTERED)
  ========================== */
  void _openMapSearch(String keyword) async {
    final query = Uri.encodeComponent('$keyword in $selectedState');
    final uri = Uri.parse('https://www.google.com/maps/search/$query');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /* =========================
     CALL HOTLINE
  ========================== */
  void _call(String number) async {
    await launchUrl(Uri.parse('tel:$number'));
  }

  /* =========================
     SCORE INTERPRETATION
  ========================== */
  Map<String, dynamic> _interpretScore(int score) {
    if (score <= 9) {
      return {
        'label': 'LOW',
        'color': Colors.green,
        'icon': Icons.check_circle,
        'details': [
          'Your emotional responses are within a manageable range.',
          'Occasional stress or low mood can occur due to daily life demands.',
          'This level typically does not interfere with daily functioning.',
          'Maintaining healthy routines, rest, and social connection is encouraged.',
        ],
      };
    } else if (score <= 14) {
      return {
        'label': 'MODERATE',
        'color': Colors.orange,
        'icon': Icons.warning_amber,
        'details': [
          'You may be experiencing noticeable emotional strain.',
          'Stress, worry, or low mood may occur more frequently.',
          'This level may begin to affect focus, motivation, or sleep.',
          'Learning coping strategies or seeking emotional support is recommended.',
        ],
      };
    } else {
      return {
        'label': 'HIGH',
        'color': Colors.red,
        'icon': Icons.error,
        'details': [
          'Your score suggests significant emotional distress.',
          'Feelings such as prolonged stress, anxiety, or low mood may be present.',
          'This level can have a strong impact on daily life and wellbeing.',
          'Professional support is strongly recommended to help manage these feelings safely.',
        ],
      };
    }
  }

  /* =========================
     PRETTY RESULT POPUP
  ========================== */
  void _showResultDialog(int score) async {
    final result = _interpretScore(score);
    await _saveResult(score, result['label']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(result['icon'], color: result['color'], size: 28),
            const SizedBox(width: 10),
            const Text('Your Result'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${result['label']} : $score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: result['color'],
                ),
              ),
              const SizedBox(height: 14),
              ...result['details']
                  .map<Widget>((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $d'),
                      ))
                  .toList(),
              const SizedBox(height: 14),
              const Text(
                'This result is not a diagnosis. If you feel unsafe or overwhelmed, please seek immediate professional support.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
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
    final states = [
      'Kuala Lumpur',
      'Selangor',
      'Johor',
      'Penang',
      'Perak',
      'Kedah',
      'Sabah',
      'Sarawak',
    ];

    final hotlines = [
      {'name': 'Emergency (999)', 'number': '999'},
      {'name': 'Befrienders KL', 'number': '0376272929'},
      {'name': 'Mental Health Helpline (MOH)', 'number': '15555'},
      {'name': 'Talian Kasih', 'number': '15999'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotline & Self-Test'),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'This Hotline & Self-Test section helps you reflect on your emotional wellbeing and find appropriate support.',
              ),
=======
          const Text('Quick self-check', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('If you feel in immediate danger, contact local emergency services. This screen contains simple guidance and hotlines.'))),
          const SizedBox(height: 16),
          const Text('Hotlines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...hotlines.map((h) => Card(
            child: ListTile(
              leading: const Icon(Icons.call),
              title: Text(h['title']!),
              subtitle: Text(h['number']!),
              onTap: () {
                // Contact action placeholder
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Would call ${h['number']} (demo)')));
              },
            ),
          ),

          const SizedBox(height: 26),

          /// 🔴 TEXT COLOR CHANGED TO WHITE
          ElevatedButton(
            onPressed: _openDASS,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'DASS TEST WEBSITE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: scoreCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter your DASS score',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 14),

          ElevatedButton(
  onPressed: () {
    final score = int.tryParse(scoreCtrl.text) ?? 0;
    _showResultDialog(score);
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primary, // purple button
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: const Text(
    'View Result',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white, // white text
    ),
  ),
),


          const SizedBox(height: 30),

          const Text(
            'Find Help by Location',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: selectedState,
            items: states
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedState = val!),
            decoration: const InputDecoration(
              labelText: 'Select your state',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          /// 🔴 TEXT + ICON COLOR CHANGED TO WHITE
          ElevatedButton.icon(
            icon: const Icon(Icons.location_on, color: Colors.white),
            label: const Text(
              'Clinics & Psychiatrists',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            onPressed: () =>
                _openMapSearch('psychiatrist or mental health clinic'),
          ),

          const SizedBox(height: 30),

          const Text(
            'Emergency & Support Hotlines',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ...hotlines.map(
            (h) => Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.call, color: Colors.red),
                title: Text(h['name']!),
                subtitle: Text(h['number']!),
                onTap: () => _call(h['number']!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

