import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/mood_tracker_screen.dart';
import '../screens/resource_library_screen.dart';
import '../screens/progress_insight_screen.dart';
import '../screens/hotline_screen.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    MoodTrackerScreen(),
    ResourceLibraryScreen(),
    ProgressInsightScreen(),
    HotlineScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: AppTheme.primaryDark,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Mood'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Resources'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Hotline'),
        ],
      ),
    );
  }
}
