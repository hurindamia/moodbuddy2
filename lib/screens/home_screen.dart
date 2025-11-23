import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/module_tile.dart';
import '../app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'title': 'Mood Tracker', 'route': '/moodtracker', 'icon': Icons.track_changes},
      {'title': 'Resource Library', 'route': '/resources', 'icon': Icons.book},
      {'title': 'Progress Insight', 'route': '/progress', 'icon': Icons.show_chart},
      {'title': 'Hotline & Self-Test', 'route': '/hotline', 'icon': Icons.phone},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoodBuddy2'),
        backgroundColor: AppTheme.primary,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const ProfileHeader(name: 'Hurin Damia', email: 'hdhur@example.com'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
                  ListTile(leading: const Icon(Icons.person), title: const Text('Profile'), onTap: () {}),
                  ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),
                  const Divider(),
                  ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, Hurin!', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            const Text('Tap any module to get started', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),

            // scroll list of modules
            Expanded(
              child: ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, i) {
                  final m = modules[i];
                  return ModuleTile(
                    title: m['title'] as String,
                    icon: m['icon'] as IconData,
                    onTap: () => Navigator.pushNamed(context, m['route'] as String),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
