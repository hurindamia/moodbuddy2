import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetailScreen extends StatelessWidget {
  final String title;
  final String desc;
  final String? thumbnail;
  final String link;

  const BookDetailScreen({
    super.key,
    required this.title,
    required this.desc,
    required this.link,
    this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Detail", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF9575CD),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (thumbnail != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(thumbnail!,
                    width: 180, height: 250, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            Text(desc, style: GoogleFonts.poppins(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text("Buy this Book"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9575CD),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle:
                  GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(link))) {
                  launchUrl(Uri.parse(link));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cannot open link")));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}