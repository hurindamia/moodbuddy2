import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsServiceScreen extends StatelessWidget {
  const TermsServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tosText = '''
Terms of Service

1. Acceptance of Terms
By downloading, installing, or using the MoodBuddy Service, you agree to be bound by these Terms and our Privacy Policy. If you do not agree, you must not use the Service.

2. CRITICAL DISCLAIMER: NO MEDICAL ADVICE
MOODBUDDY IS NOT A MEDICAL DEVICE, NOR IS IT A SUBSTITUTE FOR PROFESSIONAL MEDICAL OR MENTAL HEALTH CARE, DIAGNOSIS, OR TREATMENT.

* The information and tools provided (including mood trends, coping strategies, and the DASS assessment) are for informational and self-management purposes only.
* MoodBuddy's developers and staff are not licensed medical or mental health professionals. Always seek the advice of a qualified health provider with any questions you may have regarding a medical condition.

3. EMERGENCY WARNING
MOODBUDDY IS NOT INTENDED FOR EMERGENCY USE.

* If you are experiencing a mental health crisis, self-harm thoughts, or any emergency, immediately contact your local emergency services (e.g., 999 or 911) or a crisis hotline. Do not rely on MoodBuddy for crisis intervention.

4. User Eligibility and Account

* Minimum Age: You must be at least [Specify Age, e.g., 18] years old to use the Service, or have the explicit permission and supervision of a parent or guardian.
* Account Security: You are responsible for maintaining the confidentiality of your password and for all activities that occur under your account.

5. Intellectual Property Rights
MoodBuddy and its original content, features, and functionality are and will remain the exclusive property of MoodBuddy and its licensors. You are granted a limited, non-exclusive, non-transferable license to use the app for your personal, non-commercial use only.

6. Limitation of Liability
To the maximum extent permitted by applicable law, in no event shall MoodBuddy be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from:

(i) your use of or inability to use the Service;

(ii) any content obtained from the Service; or

(iii) unauthorized access, use, or alteration of your transmissions or content.

7. Governing Law
These Terms shall be governed and construed in accordance with the laws of [Specify Jurisdiction, e.g., Malaysia], without regard to its conflict of law provisions.

8. Changes to Terms
We reserve the right to modify or replace these Terms at any time. We will provide reasonable notice (e.g., 30 days) before any new terms take effect.
''';

    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF9575CD),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            tosText,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
