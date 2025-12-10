import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialAbout;
  final String initialEmergencyName;
  final String initialEmergencyPhone;
  final String? initialImage;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialAbout,
    required this.initialEmergencyName,
    required this.initialEmergencyPhone,
    this.initialImage,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // These are state variables, accessible within this class
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController aboutCtrl;
  late TextEditingController emergencyNameCtrl;
  late TextEditingController emergencyPhoneCtrl;

  String? pickedImagePath;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initialName);
    emailCtrl = TextEditingController(text: widget.initialEmail);
    aboutCtrl = TextEditingController(text: widget.initialAbout);
    emergencyNameCtrl = TextEditingController(text: widget.initialEmergencyName);
    emergencyPhoneCtrl = TextEditingController(text: widget.initialEmergencyPhone);
    pickedImagePath = widget.initialImage;
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  // FIX 2: MOVED _saveProfileChanges INSIDE the _EditProfileScreenState class
  // It now has access to nameCtrl, emergencyNameCtrl, etc.
  Future<void> _saveProfileChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not logged in (optional: show error)
      print("User not logged in, cannot save to Firestore.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'name': nameCtrl.text.trim(),
          'emergencyName': emergencyNameCtrl.text.trim(),
          'emergencyPhone': emergencyPhoneCtrl.text.trim(),
          'profileImage': pickedImagePath,
        },
        SetOptions(merge: true),
      );
      print("Profile saved successfully to Firestore.");
    } catch (e) {
      print("Error saving profile: $e");
      // Optional: show a snackbar to the user
    }
  }
  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  // FUNCTION 1: PICKS IMAGE FROM DEVICE GALLERY (No change)
  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? file =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (file != null) {
      setState(() => pickedImagePath = file.path);
    }
  }

  // FUNCTION 2: ALLOWS USER TO PASTE A URL (No change)
  Future<void> pickFromUrlDialog() async {
    final ctrl = TextEditingController(
        text: pickedImagePath?.startsWith('http') == true
            ? pickedImagePath
            : '');

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter image URL'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('OK')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => pickedImagePath = result);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    aboutCtrl.dispose();
    emergencyNameCtrl.dispose();
    emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF9575CD),
        centerTitle: true,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    /// ---- Profile Image Selector (Omitted for brevity) ----
                    // ... (GestureDetector, CircleAvatar logic is correct)
                    GestureDetector(
                      onTap: () async {
                        // Show modal to choose source (Gallery or URL)
                        final choice = await showModalBottomSheet<int>(
                          context: context,
                          builder: (_) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from gallery'),
                                  onTap: () => Navigator.pop(context, 1), // 1 for gallery
                                ),
                                ListTile(
                                  leading: const Icon(Icons.link),
                                  title: const Text('Use image URL'),
                                  onTap: () => Navigator.pop(context, 2), // 2 for URL
                                ),
                              ],
                            ),
                          ),
                        );

                        if (choice == 1) await pickFromGallery();
                        if (choice == 2) await pickFromUrlDialog();
                      },
                      child: Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          // Image display logic: File if local path, NetworkImage if URL, AssetImage if null
                          backgroundImage: pickedImagePath != null
                              ? (pickedImagePath!.startsWith('http')
                              ? NetworkImage(pickedImagePath!)
                              : FileImage(File(pickedImagePath!))) as ImageProvider
                              : const AssetImage('assets/images/profile.png') as ImageProvider<Object>?,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF9575CD),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ------------------------------------------------------------------

                    const SizedBox(height: 25),

                    /// ---- Input Fields (Omitted for brevity) ----
                    _buildInput("Full name / Nickname", nameCtrl),
                    const SizedBox(height: 15),
                    _buildInput("Email", emailCtrl),
                    const SizedBox(height: 15),
                    _buildInput("Emergency contact name", emergencyNameCtrl),
                    const SizedBox(height: 15),
                    _buildInput("Emergency contact phone", emergencyPhoneCtrl),
                    const SizedBox(height: 30),

                    const Spacer(),

                    /// ---- Save Button ----
                    ElevatedButton(
                      // FIX 1: MARK onPressed AS async
                      onPressed: () async {
                        await _saveProfileChanges(); // Now this runs correctly

                        // Pass back the updated data to the ProfileScreen
                        if (mounted) {
                          Navigator.pop(context, {
                            // These variables are now correctly scoped
                            'name': nameCtrl.text.trim(),
                            'email': emailCtrl.text.trim(),
                            'about': aboutCtrl.text.trim(),
                            'emergencyName': emergencyNameCtrl.text.trim(),
                            'emergencyPhone': emergencyPhoneCtrl.text.trim(),
                            'image': pickedImagePath,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9575CD),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper Input Builder (No change)
  Widget _buildInput(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}