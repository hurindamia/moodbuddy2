import 'dart:ui';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';

// Ensure these files exist in the same directory (lib/screens/)
import 'terms_service_screen.dart';
import 'about_us.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // user data (in-memory)
  late String name = '';
  late String email = '';
  late String aboutMe = '';
  late String emergencyName = '';
  late String emergencyPhone = '';
  String? profileImage; // can be local path or URL; if null use asset
  bool acceptedPrivacy = false;
  bool acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      name = doc.data()?['name'] ?? 'User';
      email = doc.data()?['email'] ?? user.email ?? '';
      emergencyName = doc.data()?['emergencyName'] ?? '';
      emergencyPhone = doc.data()?['emergencyPhone'] ?? '';
      profileImage = doc.data()?['profileImage'];
      aboutMe = doc.data()?['aboutMe'] ?? '';
    });
  }


  @override
  Widget build(BuildContext context) {
    const cardPurple = Color(0xFF9575CD);

    VoidCallback? _logout;
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.poppins()),
        backgroundColor: cardPurple,
      ),
      body: Stack(
        children: [
          // Background image (network) and blur
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/736x/7a/17/ac/7a17ac6c1baac75e8a95acfe9badd831.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[200]), // Fallback
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.white.withOpacity(0.2)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Header: avatar, name, email
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profileImage != null
                              ? (profileImage!.startsWith('http')
                                  ? NetworkImage(profileImage!) as ImageProvider
                                  : FileImage(File(profileImage!))
                                      as ImageProvider)
                              : const AssetImage('assets/images/profile.png'),
                        ),
                        const SizedBox(height: 12),
                        Text(name,
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.w600)),
                        Text(email,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey.shade800)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 18),

                  // Personal Information
                  Text('Personal Information',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _infoTile('Full Name', name),
                  _infoTile('Email', email),
                  _infoTile('Full Name', name), // DYNAMIC
                  _infoTile('Email', email), // DYNAMIC

                  const SizedBox(height: 18),

                  // Emergency Contact
                  Text('Emergency Contact',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _infoTile('Name', emergencyName),
                  _infoTile('Phone', emergencyPhone),

                  const SizedBox(height: 22),

                  // ABOUT US BOX (same style as Privacy Policy)
                  _infoTile('Name',
                      emergencyName.isEmpty ? 'Not Set' : emergencyName),
                  _infoTile('Phone',
                      emergencyPhone.isEmpty ? 'Not Set' : emergencyPhone),

                  const SizedBox(height: 22),

                  // ABOUT US BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF9575CD).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.info_outline,
                                  color: Color(0xFF9575CD)),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'About Us',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Clickable ListTile
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.arrow_right,
                              color: Colors.black54),
                          title: Text('View details',
                              style: GoogleFonts.poppins()),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AboutUsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Policies & Agreements (modern card style)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cardPurple.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  const Icon(Icons.policy, color: cardPurple),
                            ),
                            const SizedBox(width: 12),
                            Text('Policies & Agreements',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Privacy Policy row
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.privacy_tip_outlined,
                              color: Colors.black54),
                          title: Text('Privacy Policy',
                              style: GoogleFonts.poppins()),
                          subtitle: Text(
                            'View details',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final result = await Navigator.push<bool?>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            );

                            if (result == true) {
                              setState(() => acceptedPrivacy = true);
                            } else if (result == false) {
                              setState(() => acceptedPrivacy = false);
                            }
                          },
                        ),
                        const Divider(),
                        // Terms of Service row
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.description_outlined,
                              color: Colors.black54),
                          title: Text('Terms of Service',
                              style: GoogleFonts.poppins()),
                          subtitle: Text(
                            'View details',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen()),
                            );
                            final result = await Navigator.push<bool?>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const TermsServiceScreen()),
                            );

                            if (result == true) {
                              setState(() => acceptedTerms = true);
                            } else if (result == false) {
                              setState(() => acceptedTerms = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Edit Profile button
                  ElevatedButton(
                    onPressed: () async {
                      // Navigate to EditProfileScreen and await result
                      final updated =
                          await Navigator.push<Map<String, dynamic>?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            initialName: name,
                            initialEmail: email,
                            initialAbout: aboutMe,
                            initialEmergencyName: emergencyName,
                            initialEmergencyPhone: emergencyPhone,
                            initialImage: profileImage,
                          ),
                        ),
                      );

                      // Update state if new data was returned
                      if (updated != null) {
                        setState(() {
                          name = updated['name'] ?? name;
                          email = updated['email'] ?? email;
                          aboutMe = updated['about'] ?? aboutMe;
                          emergencyName =
                              updated['emergencyName'] ?? emergencyName;
                          emergencyPhone =
                              updated['emergencyPhone'] ?? emergencyPhone;
                          profileImage = updated['image'] ?? profileImage;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9575CD),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Edit Profile',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white)),
                  ),

                  const SizedBox(height: 15),

                  // LOGOUT BUTTON (Correctly placed inside the Column)
                  ElevatedButton(
                    onPressed:
                        _logout, // Calls the Firebase sign-out and navigation function
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red.shade400, // Clear indicator for Logout
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Logout',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.white)),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
