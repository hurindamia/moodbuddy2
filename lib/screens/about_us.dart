import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Us",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🌟 About MoodBuddy
            Text("🌟 About MoodBuddy",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              "MoodBuddy is a comprehensive and interactive mobile application dedicated to supporting emotional well-being, promoting self-awareness, and encouraging proactive mental health management in response to the global rise in mental health challenges.",
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 25),

            // 🎯 Mission
            Text("🎯 Our mission and the problem we address",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              "Mental health challenges like anxiety, depression, and stress are increasingly prevalent, particularly among youth and working adults facing high pressure and uncertainty. Despite growing awareness, many individuals are reluctant to seek help due to persistent stigma, fear of judgment, and the lack of accessible or affordable professional support.",
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 10),
            Text(
              "The urgency of this issue is highlighted by local data, such as the National Health and Morbidity Survey 2023, which shows the number of Malaysians experiencing depression doubled from 2.3% in 2019 to 4.6% in 2023 due to rising stress and a shortage of mental health professionals.",
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 10),
            Text(
              "MoodBuddy addresses this critical need by providing an accessible, digital, and preventive solution that leverages the ubiquity of smartphones for consistent, portable, and personal engagement.",
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 25),

            // ✨ Key Features
            Text("✨ Key features and how we help",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              "MoodBuddy is designed with an intuitive and user-friendly interface and integrates a variety of features to make mental health management engaging and insightful:",
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 10),

            _bullet("* Gamified mood tracking: emotional check-ins are transformed into engaging daily activities"),
            _bullet("* Interactive mini-games: playful yet insightful games are used to assess emotional states"),
            _bullet("* Personalized resource library: provides users with relevant coping strategies, mindfulness exercises, and educational content"),
            _bullet("* Validated self-assessment: uses tools like the Depression Anxiety Stress Scale (DASS) for mental health evaluation"),
            _bullet("* Data visualization: presents mood trends through charts and graphs to help users identify triggers and patterns"),

            const SizedBox(height: 25),

            // 🚀 Our Goal
            Text("🚀 Our goal",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              "Our goal is to deliver an engaging, inclusive, and preventive digital solution that helps break down barriers to mental health care. MoodBuddy empowers individuals to take charge of their emotional well-being and contributes to the broader effort of destigmatizing mental health support in society.",
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for bullet points
  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
      ),
    );
  }
}
