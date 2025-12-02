import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../app_theme.dart';
import 'profile_screen.dart';
import '../widgets/module_tile.dart';
import 'mood_tracker_screen.dart';
import 'resource_library_screen.dart';
import 'progress_insight_screen.dart';
import 'hotline_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeBody(),              // custom widget for home page
    MoodTrackerScreen(),
    ResourceLibraryScreen(),
    ProgressInsightScreen(),
    HotlineScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MoodBuddy2"),
        backgroundColor: AppTheme.primary,
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const ProfileHeader(
              name: 'Hurin Damia',
              email: 'hdhur@example.com',
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: "Mood",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Resources",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Progress",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: "Hotline",
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'title': 'Mood Tracker', 'route': '/moodtracker', 'icon': Icons.track_changes},
      {'title': 'Resource Library', 'route': '/resources', 'icon': Icons.book},
      {'title': 'Progress Insight', 'route': '/progress', 'icon': Icons.show_chart},
      {'title': 'Hotline & Self-Test', 'route': '/hotline', 'icon': Icons.phone},
    ];

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back, Hurin!', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          const Text('Tap any module to get started', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),

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
    );
  }
}
