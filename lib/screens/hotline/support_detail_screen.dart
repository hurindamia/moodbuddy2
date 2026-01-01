import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/support_option.dart';
import '../../app_theme.dart';
import '../../widgets/clinic_card_widget.dart';


class SupportDetailScreen extends StatelessWidget {
  final SupportOption option;

  const SupportDetailScreen({
    super.key,
    required this.option,
  });

  void _openWebsite(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openMap(String query) async {
    await launchUrl(
      Uri.parse(
        'https://www.google.com/maps/search/${Uri.encodeComponent(query)}',
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(option.title),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /* =========================
             HEADER IMAGE
          ========================== */
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              option.imagePath ??
                  'assets/images/mental_health_illustration.png',
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),

          /* =========================
             TITLE
          ========================== */
          Text(
            option.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          /* =========================
             DESCRIPTION
          ========================== */
          Text(
            option.description,
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _openMap(option.locationQuery),
            child: const Text(
              'View Location in Google Maps',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),

          /* =========================
             PEGAWAI PSIKOLOGI
          ========================== */
          if (option.psychologists != null) ...[
            const Text(
              'Pegawai Psikologi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...option.psychologists!,
          ],

          if (option.clinics != null) ...[
  const Text(
    'Clinics & Hospitals',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 12),
  ...option.clinics!
      .map((c) => ClinicCardWidget(clinic: c))
      .toList(),
],



          const SizedBox(height: 10),

          /* =========================
             QUICK ACTIONS
          ========================== */
          const Text(
            'Visit Website 👇',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (option.website != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _openWebsite(option.website!),
              child: const Text(
                'Book Appointment / Visit Website',
                style: TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(height: 30),

          /* =========================
             APP LOGO (BOTTOM)
          ========================== */
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/moodbuddy_logo3.png',
                  height: 120,
                ),
                const SizedBox(height: 10),
                const Text(
                  'MoodBuddy\nSupporting Student Wellbeing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
