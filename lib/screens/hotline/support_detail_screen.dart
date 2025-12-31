import 'package:flutter/material.dart';
import '../../models/support_option.dart';

class SupportDetailScreen extends StatelessWidget {
  final SupportOption option;

  const SupportDetailScreen({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(option.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          option.description,
          style: const TextStyle(height: 1.5),
        ),
      ),
    );
  }
}
