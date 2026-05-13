enum UserRole {
  admin,
  owner,
  agent,
  helper,
}

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? agencyId; // For agents and helpers
  final String? gangId; // For owners
  final List<String>? managedAgencyIds; // Legacy or additional flexibility

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.agencyId,
    this.gangId,
    this.managedAgencyIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name,
      'agencyId': agencyId,
      'gangId': gangId,
      'managedAgencyIds': managedAgencyIds,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.helper,
      ),
      agencyId: map['agencyId'],
      gangId: map['gangId'],
      managedAgencyIds: map['managedAgencyIds'] != null 
          ? List<String>.from(map['managedAgencyIds']) 
          : null,
    );
  }
}
