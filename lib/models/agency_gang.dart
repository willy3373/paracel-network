class AgencyGang {
  final String id;
  final String name;
  final List<String> agencyIds;
  final List<String> lines;
  final double fee;
  final bool isBlocked;

  AgencyGang({
    required this.id,
    required this.name,
    required this.agencyIds,
    this.lines = const [],
    this.fee = 0.0,
    this.isBlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'agencyIds': agencyIds,
      'lines': lines,
      'fee': fee,
      'isBlocked': isBlocked,
    };
  }

  factory AgencyGang.fromMap(String id, Map<String, dynamic> map) {
    return AgencyGang(
      id: id,
      name: map['name'] ?? '',
      agencyIds: List<String>.from(map['agencyIds'] ?? []),
      lines: List<String>.from(map['lines'] ?? []),
      fee: (map['fee'] ?? 0.0).toDouble(),
      isBlocked: map['isBlocked'] == true,
    );
  }
}
