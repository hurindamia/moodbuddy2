import 'package:flutter/material.dart';

class PsychologistCard extends StatelessWidget {
  final String name;
  final String position;
  final String department;
  final String phone;
  final String email;
  final String? imagePath;
  final bool expandable;

  const PsychologistCard({
    super.key,
    required this.name,
    required this.position,
    required this.department,
    required this.phone,
    required this.email,
    this.imagePath,
    this.expandable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      tilePadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage:
            imagePath != null ? AssetImage(imagePath!) : null,
        child: imagePath == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(position),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(department),
              const SizedBox(height: 6),
              Text('☎ $phone'),
              Text('📧 $email'),
            ],
          ),
        ),
      ],
    );
  }
}
