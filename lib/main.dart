import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/resource_library_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/progress_insight_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/hotline/hotline_screen.dart';
import 'widgets/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MoodBuddyApp());
}

class MoodBuddyApp extends StatelessWidget {
  const MoodBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodBuddy2',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        // REMOVED 'const' from dynamic layouts
        '/home': (_) => const MainLayout(initialIndex: 0),
        '/moodtracker': (_) => const MoodTrackerScreen(),
        '/resources': (_) => const ResourceLibraryScreen(),
        '/progress': (_) => const ProgressInsightScreen(),
        '/hotline': (_) => const HotlineScreen(),
        // ProfileScreen now works without arguments
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}