// ignore: unused_import
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    options: DefaultFirebaseOptions.currentPlatform, // if using FlutterFire CLI
  );
  //await dotenv.load(fileName: ".env");
  //print(dotenv.env['HF_API_KEY']); // should print your key
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
        '/home': (_) => const MainLayout(initialIndex:0),
        '/moodtracker': (_) => MoodTrackerScreen(),
        '/resources': (_) => ResourceLibraryScreen(),
        '/progress': (_) => ProgressInsightScreen(),
        '/hotline': (_) => HotlineScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
