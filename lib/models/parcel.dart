class Parcel {
  final String id;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String originAgencyId;
  final String destinationAgencyId;
  final double weight;
  final double amount;
  final String label;
  final String trackingCode;
  final String status; // 'pending', 'in_transit', 'arrived', 'delivered'
  final DateTime createdAt;
  final bool isPayOnDelivery;

  Parcel({
    required this.id,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.originAgencyId,
    required this.destinationAgencyId,
    required this.weight,
    required this.amount,
    required this.label,
    required this.trackingCode,
    required this.status,
    required this.createdAt,
    required this.isPayOnDelivery,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderName': senderName,
      'senderPhone': senderPhone,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'originAgencyId': originAgencyId,
      'destinationAgencyId': destinationAgencyId,
      'weight': weight,
      'amount': amount,
      'label': label,
      'trackingCode': trackingCode,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'isPayOnDelivery': isPayOnDelivery,
    };
  }

  factory Parcel.fromMap(Map<String, dynamic> map, String id) {
    return Parcel(
      id: id,
      senderName: map['senderName'] ?? '',
      senderPhone: map['senderPhone'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverPhone: map['receiverPhone'] ?? '',
      originAgencyId: map['originAgencyId'] ?? '',
      destinationAgencyId: map['destinationAgencyId'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      amount: (map['amount'] ?? 0.0).toDouble(),
      label: map['label'] ?? '',
      trackingCode: map['trackingCode'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      isPayOnDelivery: map['isPayOnDelivery'] ?? false,
    );
  }
}
