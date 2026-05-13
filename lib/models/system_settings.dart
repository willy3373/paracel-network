import 'package:cloud_firestore/cloud_firestore.dart';

class SystemSettings {
  final String appName;
  final double defaultFee;
  final String supportContact;
  final bool maintenanceMode;

  SystemSettings({
    required this.appName,
    required this.defaultFee,
    required this.supportContact,
    required this.maintenanceMode,
  });

  factory SystemSettings.fromMap(Map<String, dynamic> map) {
    return SystemSettings(
      appName: map['appName'] ?? 'Pick Pack',
      defaultFee: (map['defaultFee'] ?? 0.0).toDouble(),
      supportContact: map['supportContact'] ?? '',
      maintenanceMode: map['maintenanceMode'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'defaultFee': defaultFee,
      'supportContact': supportContact,
      'maintenanceMode': maintenanceMode,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory SystemSettings.defaultSettings() {
    return SystemSettings(
      appName: 'Pick Pack',
      defaultFee: 100.0,
      supportContact: '',
      maintenanceMode: false,
    );
  }
}
