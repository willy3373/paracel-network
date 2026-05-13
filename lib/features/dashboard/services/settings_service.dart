import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_pack/models/system_settings.dart';

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _settingsPath = 'settings/global';

  Stream<SystemSettings> settingsStream() {
    return _db.doc(_settingsPath).snapshots().map((snap) {
      if (!snap.exists) return SystemSettings.defaultSettings();
      return SystemSettings.fromMap(snap.data()!);
    });
  }

  Future<SystemSettings> getSettings() async {
    try {
      final snap = await _db.doc(_settingsPath).get();
      if (!snap.exists) {
        final defaults = SystemSettings.defaultSettings();
        await _db.doc(_settingsPath).set(defaults.toMap());
        return defaults;
      }
      return SystemSettings.fromMap(snap.data()!);
    } catch (e) {
      return SystemSettings.defaultSettings();
    }
  }

  Future<String?> updateSettings(SystemSettings settings) async {
    try {
      await _db.doc(_settingsPath).set(settings.toMap(), SetOptions(merge: true));
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
