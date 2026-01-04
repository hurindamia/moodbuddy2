import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const ppText = '''
    Privacy Policy
    
    This Privacy Policy describes how MoodBuddy ("we," "us," or "our") collects, uses, and protects your personal information and sensitive health data when you use the MoodBuddy mobile application (the "Service"). Your trust is essential, and protecting your confidential mental health information is our highest priority.
    
    1. Data We Collect and Why
    We collect different types of data to provide and continuously improve our Service.
    
    A. Identity Data: We collect your name, email address, username, and encrypted password during account creation. Purpose: For security, communication, account management, and providing support.
    B. Sensitive Health Data: This includes mood inputs, journal entries, DASS assessment results, stress levels, and emotional state data. Purpose: This is the core data used to personalize your experience, generate trend analyses, and offer relevant coping strategies within the app.
    C. Usage and Technical Data: We collect data about how you interact with the app (features used, time of access, device type, IP address). Purpose: To monitor app performance, identify technical issues, and improve the user interface and functionality.
    
    2. How We Use and Protect Your Data
    We use your data strictly to deliver and enhance the MoodBuddy Service.
    
    * Service Provision: Your data is used internally to provide the personalized features of the app (e.g., displaying your mood charts, suggesting specific exercises).
    * NO SALE OF DATA: We will NOT sell, rent, or trade your Sensitive Health Data to third parties for marketing, advertising, or any other commercial purposes.
    * Anonymized Research: We may use your data in an aggregated and completely de-identified form (stripped of all identifying information) for research, statistical analysis, or to inform future public health efforts. Your individual identity will never be revealed in this process.
    * Security Measures: We use industry-standard technical safeguards, including encryption (for data in transit and at rest), secure server hosting, and strict access controls to protect your data from unauthorized access.
    
    3. Disclosure of Your Personal Data
    We will not share your data except in these limited, specific circumstances:
    
    * With Your Consent: If you provide your explicit, written consent for a specific disclosure.
    * Legal Obligation: If we are compelled to disclose data by a court order or other legal process required by law.
    * Imminent Harm: If we have a good faith belief that disclosure is necessary to prevent immediate and serious harm to you or to others.
    * Service Providers: With third-party service providers (like cloud hosting platforms) who are contractually bound to maintain confidentiality and use the data only for the purpose of providing services to us.
    
    4. Your Data Protection Rights
    You have control over your data and can exercise these rights at any time:
    
    * Right to Access: You can request a copy of the personal data we hold about you.
    * Right to Rectification: You can request the correction of inaccurate or incomplete data you have provided.
    * Right to Deletion (Right to be Forgotten): You can request the complete and permanent deletion of your MoodBuddy account and all associated personal data (subject to minimal legal data retention requirements).
    * Right to Withdraw Consent: You can withdraw your consent to the processing of your data at any time by deleting your account or contacting us.
    
    5. Children's Privacy
    The Service is not intended for use by anyone under the age of [Specify Age, e.g., 13]. If you are a parent or guardian and become aware that your child has provided us with personal data, please contact us.
    
    6. Changes to This Policy
    We may update this Privacy Policy periodically. We will notify you of any significant changes by posting the new Policy on this page and updating the "Effective Date" at the top. Your continued use of the Service after changes constitutes your acceptance of the revised Policy.
    ''';

    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF9575CD),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            ppText,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ),
    );
  }
}