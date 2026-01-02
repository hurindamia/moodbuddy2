
class ClinicCard {
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final String locationQuery;
  final String imagePath;

  const ClinicCard({
    required this.name,
    required this.address,
    required this.phone,
    required this.locationQuery,
    required this.imagePath,
    this.email,
    this.website,
  });
}
