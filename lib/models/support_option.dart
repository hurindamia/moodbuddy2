import 'package:flutter/material.dart';
import 'clinic_card.dart';

class SupportOption {
  final String title;
  final String description;
  final String locationQuery;
  final String? address;
  final String? website;
  final String? imagePath;
  final List<Widget>? psychologists;
  final List<ClinicCard>? clinics;
  final bool showWebsiteButton;



  SupportOption({
    required this.title,
    required this.description,
    required this.locationQuery,
    this.address,
    this.website,
    this.imagePath,
    this.psychologists,
    this.clinics,
    this.showWebsiteButton = true,
  });
}
