import 'package:flutter/material.dart';
import 'app_theme.dart';

// Existing screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/resource_library_screen.dart';
import 'screens/progress_insight_screen.dart';
import 'screens/hotline_screen.dart';

// New screens
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_service_screen.dart';
import 'screens/about_us.dart';

void main() {
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
      initialRoute: '/login',

      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => HomeScreen(),
        '/moodtracker': (_) => MoodTrackerScreen(),
        '/resources': (_) => ResourceLibraryScreen(),
        '/progress': (_) => ProgressInsightScreen(),
        '/hotline': (_) => HotlineScreen(),
        '/about': (_) => AboutUsScreen(),

        // Profile
        '/profile': (_) => ProfileScreen(),

        // Edit profile (requires parameters)
        '/editprofile': (_) => EditProfileScreen(
          initialName: "",
          initialEmail: "",
          initialAbout: "",
          initialEmergencyName: "",
          initialEmergencyPhone: "",
        ),

        // Legal
        '/privacy': (_) => PrivacyPolicyScreen(),
        '/terms': (_) => TermsServiceScreen(),
      },
    );
  }
}
