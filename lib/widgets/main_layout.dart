import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/mood_tracker_screen.dart';
import '../screens/resource_library_screen.dart';
import '../screens/progress_insight_screen.dart';
import '../screens/hotline/hotline_screen.dart';
import '../app_theme.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  final double? initialMood;

  const MainLayout({super.key, required this.initialIndex, this.initialMood});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _pages = [
      const HomeScreen(), // index 0
      MoodTrackerScreen(
        initialMood: widget.initialMood, // quick emoji mood button
      ), // index 1
      const ResourceLibraryScreen(), // index 2
      const ProgressInsightScreen(), // index 3
      const HotlineScreen(), // index 4
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: "Mood"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Resources"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: "Hotline"),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
