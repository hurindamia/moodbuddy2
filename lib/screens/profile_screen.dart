import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const lightPurple = Color(0xFFEDE7F6);
    const purpleButton = Color(0xFF9575CD);

    return Scaffold(
      // ---------------------------
      // Background Image
      // ---------------------------
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://i.pinimg.com/736x/7a/17/ac/7a17ac6c1baac75e8a95acfe9badd831.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),

        // ---------------------------
        // Blur Overlay
        // ---------------------------
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.white.withOpacity(0.2),

            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ---------------------------
                    // AppBar
                    // ---------------------------
                    Center(
                      child: Text(
                        "Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------------------
                    // Profile Header
                    // ---------------------------
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: const AssetImage('assets/images/profile.png'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Hurin Damia",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "hdhur@example.com",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ---------------------------
                    // Personal Information
                    // ---------------------------
                    Text(
                      "Personal Information",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _infoTile("Full Name", "Hurin Damia", lightPurple),
                    _infoTile("Email", "hdhur@example.com", lightPurple),

                    const SizedBox(height: 25),

                    // ---------------------------
                    // Emergency Contact
                    // ---------------------------
                    Text(
                      "Emergency Contact",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _infoTile("Name", "Aunty Siti", lightPurple),
                    _infoTile("Phone", "+60 12-345 6789", lightPurple),

                    const SizedBox(height: 35),

                    // ---------------------------
                    // Edit Profile Button (Purple)
                    // ---------------------------
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Edit feature coming soon!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purpleButton,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // Info Tile Widget
  // ---------------------------
  Widget _infoTile(String title, String value, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
