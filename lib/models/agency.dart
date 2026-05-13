class Agency {
  final String id;
  final String name;
  final String phone;
  final String location;
  final String city;
  final String description;
  final String logoUrl;
  final String email;
  final String? gangLine;
  final bool isBlocked;

  Agency({
    required this.id,
    required this.name,
    required this.phone,
    this.location = '',
    this.city = '',
    this.description = '',
    this.logoUrl = '',
    this.email = '',
    this.gangLine,
    this.isBlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'location': location,
      'city': city,
      'description': description,
      'logoUrl': logoUrl,
      'email': email,
      'gangLine': gangLine,
      'isBlocked': isBlocked,
    };
  }

  factory Agency.fromMap(String id, Map<String, dynamic> map) {
    return Agency(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      city: map['city'] ?? '',
      description: map['description'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      email: map['email'] ?? '',
      gangLine: map['gangLine'],
      isBlocked: map['isBlocked'] == true,
    );
  }
}
