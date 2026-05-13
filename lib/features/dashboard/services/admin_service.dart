import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pick_pack/models/agency.dart';
import 'package:pick_pack/models/agency_gang.dart';
import 'package:pick_pack/models/parcel.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Agencies ──────────────────────────────────────────────────────────────

  Stream<List<Agency>> agenciesStream() {
    return _db.collection('agencies').orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => Agency.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<String?> addAgency({
    required String name,
    required String phone,
    required String city,
    String description = '',
    String logoUrl = '',
    String? gangId,
    String? gangLine,
  }) async {
    try {
      if (name.trim().isEmpty) return 'Agency name is required.';
      if (phone.trim().isEmpty) return 'Phone number is required.';
      if (city.trim().isEmpty) return 'City is required.';
      final ref = _db.collection('agencies').doc();
      await ref.set({
        'id': ref.id,
        'name': name.trim(),
        'phone': phone.trim(),
        'city': city.trim(),
        'description': description.trim(),
        'logoUrl': logoUrl.trim(),
        'gangLine': gangLine,
        'location': '',
        'email': '',
        'isBlocked': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (gangId != null && gangId.isNotEmpty) {
        await _db.collection('gangs').doc(gangId).update({
          'agencyIds': FieldValue.arrayUnion([ref.id]),
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateAgency({
    required String id,
    required String name,
    required String phone,
    required String city,
    String description = '',
    String logoUrl = '',
    String? gangId,
    String? gangLine,
  }) async {
    try {
      await _db.collection('agencies').doc(id).update({
        'name': name.trim(),
        'phone': phone.trim(),
        'city': city.trim(),
        'description': description.trim(),
        'logoUrl': logoUrl.trim(),
        'gangLine': gangLine,
      });
      // Updating gangId is complex because we'd need to remove from old gang and add to new.
      // For now we just update the basic info.
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteAgency(String agencyId) async {
    try {
      await _db.collection('agencies').doc(agencyId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleBlockAgency(String agencyId, bool currentlyBlocked) async {
    try {
      await _db.collection('agencies').doc(agencyId).update({
        'isBlocked': !currentlyBlocked,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Gangs ─────────────────────────────────────────────────────────────────

  Stream<List<AgencyGang>> gangsStream() {
    return _db.collection('gangs').orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => AgencyGang.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<String?> createGang({
    required String name,
    required List<String> agencyIds,
    List<String> lines = const [],
    double fee = 0.0,
  }) async {
    try {
      if (name.trim().isEmpty) return 'Gang name is required.';
      final ref = _db.collection('gangs').doc();
      await ref.set({
        'id': ref.id,
        'name': name.trim(),
        'agencyIds': agencyIds,
        'lines': lines,
        'fee': fee,
        'isBlocked': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateGang({
    required String id, 
    required String name, 
    required List<String> agencyIds, 
    required List<String> lines,
    required double fee
  }) async {
    try {
      await _db.collection('gangs').doc(id).update({
        'name': name.trim(),
        'agencyIds': agencyIds,
        'lines': lines,
        'fee': fee,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleBlockGang(String gangId, bool currentlyBlocked) async {
    try {
      await _db.collection('gangs').doc(gangId).update({
        'isBlocked': !currentlyBlocked,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteGang(String gangId) async {
    try {
      await _db.collection('gangs').doc(gangId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> usersStream() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => d.data()).toList(),
        );
  }

  Future<String?> deleteUser(String uid) async {
    try {
      await _db.collection('users').doc(uid).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleBlockUser(String uid, bool currentlyBlocked) async {
    try {
      await _db.collection('users').doc(uid).update({
        'isBlocked': !currentlyBlocked,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateUserProfile({
    required String uid,
    required String name,
    required String role,
    String? agencyId,
    String? gangId,
    required String email,
  }) async {
    try {
      await _db.collection('users').doc(uid).update({
        'name': name,
        'role': role,
        'agencyId': agencyId,
        'gangId': gangId,
        'email': email,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> resetUserPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Parcels ───────────────────────────────────────────────────────────────
  
  Stream<List<Parcel>> allParcelsStream() {
    return _db.collection('parcels').orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => Parcel.fromMap(d.data(), d.id)).toList(),
        );
  }
}
