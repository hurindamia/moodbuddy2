import 'package:flutter/material.dart';
import '../app_theme.dart';

class HotlineScreen extends StatelessWidget {
  const HotlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hotlines = [
      {'title': 'Befrienders', 'number': '+603-7627 2929'},
      {'title': 'Malaysia Mental Health', 'number': '+603-1234 5678'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hotline & Self-test'), backgroundColor: AppTheme.primary),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
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
          )),
        ],
      ),
    );
  }
}
