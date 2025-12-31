import 'package:flutter/material.dart';

class SupportOption {
  final String title;
  final String description;
  final String locationQuery;
  final String? address;
  final String? website;
  final String? imagePath;
  final List<Widget>? psychologists;

  SupportOption({
    required this.title,
    required this.description,
    required this.locationQuery,
    this.address,
    this.website,
    this.imagePath,
    this.psychologists,
  });
}
