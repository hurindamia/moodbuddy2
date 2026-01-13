import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_service_screen.dart';
import 'about_us.dart';

class ProfileScreen extends StatefulWidget {
  // Parameters are now optional (?) to support direct routing from main.dart
  final String? initialName;
  final String? initialEmail;
  final String? initialEmergencyName;
  final String? initialEmergencyPhone;
  final String? initialImage;

  const ProfileScreen({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialEmergencyName,
    this.initialEmergencyPhone,
    this.initialImage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name;
  late String email;
  late String emergencyName;
  late String emergencyPhone;
  String aboutMe = "I love building helpful apps and learning UX.";
  String? profileImage;
  bool acceptedPrivacy = false;
  bool acceptedTerms = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Logic: Use provided data OR fetch from Firebase
    if (widget.initialName != null) {
      name = widget.initialName!;
      email = widget.initialEmail ?? "";
      emergencyName = widget.initialEmergencyName ?? "";
      emergencyPhone = widget.initialEmergencyPhone ?? "";
      profileImage = widget.initialImage;
      isLoading = false;
    } else {
      _loadFirebaseData();
    }
  }

  Future<void> _loadFirebaseData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          name = data['name'] ?? 'User';
          email = user.email ?? 'No Email';
          emergencyName = data['emergencyName'] ?? '';
          emergencyPhone = data['emergencyPhone'] ?? '';
          profileImage = data['profileImage'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const cardPurple = Color(0xFF9575CD);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.poppins()),
        backgroundColor: cardPurple,
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background1.png'),
                    fit: BoxFit.cover,
                    opacity: 0.7,
                  ),
                ),
              )
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: profileImage != null
                              ? (profileImage!.startsWith('http')
                              ? NetworkImage(profileImage!) as ImageProvider
                              : FileImage(File(profileImage!)) as ImageProvider)
                              : const AssetImage('assets/images/profile.png') as ImageProvider<Object>?,
                        ),
                        const SizedBox(height: 12),
                        Text(name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                        Text(email, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Personal Information', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _infoTile('Full Name', name),
                  _infoTile('Email', email),
                  const SizedBox(height: 18),
                  Text('Emergency Contact', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _infoTile('Name', emergencyName.isEmpty ? 'Not Set' : emergencyName),
                  _infoTile('Phone', emergencyPhone.isEmpty ? 'Not Set' : emergencyPhone),
                  const SizedBox(height: 22),

                  // About Us Container
                  _buildCardContainer(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.arrow_right, color: Colors.black54),
                      title: Text('View details', style: GoogleFonts.poppins()),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                    ),
                  ),

                  // Policies Container
                  _buildCardContainer(
                    icon: Icons.policy,
                    title: 'Policies & Agreements',
                    child: Column(
                      children: [
                        _policyListTile('Privacy Policy', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
                        const Divider(),
                        _policyListTile('Terms of Service', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsServiceScreen()))),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () async {
                      final updated = await Navigator.push<Map<String, dynamic>?>(
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
                      if (updated != null) {
                        setState(() {
                          name = updated['name'] ?? name;
                          email = updated['email'] ?? email;
                          aboutMe = updated['about'] ?? aboutMe;
                          emergencyName = updated['emergencyName'] ?? emergencyName;
                          emergencyPhone = updated['emergencyPhone'] ?? emergencyPhone;
                          profileImage = updated['image'] ?? profileImage;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Edit Profile', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Logout', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
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

  Widget _buildCardContainer({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF9575CD).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: const Color(0xFF9575CD)),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _policyListTile(String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.description_outlined, color: Colors.black54),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _infoTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.poppins(color: Colors.black87))),
        ],
      ),
    );
  }
}