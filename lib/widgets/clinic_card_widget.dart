import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/clinic_card.dart';
import '../app_theme.dart';

class ClinicCardWidget extends StatelessWidget {
  final ClinicCard clinic;

  const ClinicCardWidget({super.key, required this.clinic});

  void _openMap() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/${Uri.encodeComponent(clinic.locationQuery)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _call() async {
    await launchUrl(Uri.parse('tel:${clinic.phone}'));
  }

  void _openWebsite() async {
    if (clinic.website != null) {
      await launchUrl(
        Uri.parse(clinic.website!),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* IMAGE */
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              clinic.imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  clinic.address,
                  style: const TextStyle(fontSize: 13),
                ),

                const SizedBox(height: 6),

                Text('📞 ${clinic.phone}', style: const TextStyle(fontSize: 13)),

                if (clinic.email != null)
                  Text('✉️ ${clinic.email}', style: const TextStyle(fontSize: 13)),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                        ),
                        onPressed: _openMap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: _call,
                    ),
                    if (clinic.website != null)
                      IconButton(
                        icon: const Icon(Icons.public),
                        onPressed: _openWebsite,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
