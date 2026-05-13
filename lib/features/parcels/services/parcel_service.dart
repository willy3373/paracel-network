import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pick_pack/models/agency.dart';
import 'package:pick_pack/models/parcel.dart';

class ParcelService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Agency>> getAgenciesInSameGang(String currentAgencyId) async {
    try {
      if (currentAgencyId.isEmpty) return [];

      final gangsSnap = await _db
          .collection('gangs')
          .where('agencyIds', arrayContains: currentAgencyId)
          .get();

      final Set<String> relatedAgencyIds = {};
      for (var doc in gangsSnap.docs) {
        final List<dynamic> ids = doc.data()['agencyIds'] ?? [];
        for (var id in ids) {
          if (id.toString() != currentAgencyId) {
            relatedAgencyIds.add(id.toString());
          }
        }
      }

      if (relatedAgencyIds.isEmpty) return [];

      List<Agency> result = [];
      final idsList = relatedAgencyIds.toList();
      for (var i = 0; i < idsList.length; i += 10) {
        final chunk = idsList.sublist(i, i + 10 > idsList.length ? idsList.length : i + 10);
        final agSnap = await _db.collection('agencies').where('id', whereIn: chunk).get();
        result.addAll(agSnap.docs.map((d) => Agency.fromMap(d.id, d.data())).toList());
      }
      
      return result;
    } catch (e) {
      debugPrint('Error fetching related agencies: $e');
      return [];
    }
  }

  Future<String?> createParcel(Parcel parcel) async {
    try {
      final docRef = _db.collection('parcels').doc(parcel.id);
      
      String finalTrackingCode = parcel.trackingCode;
      if (finalTrackingCode.isEmpty) {
        final random = Random();
        final randomString = List.generate(8, (_) => random.nextInt(10).toString()).join();
        finalTrackingCode = 'PCK-$randomString';
      }

      final parcelToSave = Parcel(
        id: parcel.id,
        senderName: parcel.senderName,
        senderPhone: parcel.senderPhone,
        receiverName: parcel.receiverName,
        receiverPhone: parcel.receiverPhone,
        originAgencyId: parcel.originAgencyId,
        destinationAgencyId: parcel.destinationAgencyId,
        weight: parcel.weight,
        amount: parcel.amount,
        label: parcel.label,
        trackingCode: finalTrackingCode,
        status: parcel.status,
        createdAt: parcel.createdAt,
        isPayOnDelivery: parcel.isPayOnDelivery,
      );

      await docRef.set(parcelToSave.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateParcelStatus(String parcelId, String status) async {
    try {
      await _db.collection('parcels').doc(parcelId).update({'status': status});
    } catch (e) {
      debugPrint('Error updating parcel status: $e');
      throw Exception('Failed to update status');
    }
  }

  Future<double> getGangFeeForAgency(String agencyId) async {
    try {
      if (agencyId.isEmpty) return 0.0;
      
      // 1. Try to get gang fee
      final snap = await _db.collection('gangs').where('agencyIds', arrayContains: agencyId).limit(1).get();
      if (snap.docs.isNotEmpty) {
        final gangFee = (snap.docs.first.data()['fee'] ?? 0.0).toDouble();
        if (gangFee > 0) return gangFee;
      }

      // 2. Fallback to global setting
      final settingsSnap = await _db.collection('settings').doc('global').get();
      if (settingsSnap.exists) {
        return (settingsSnap.data()?['defaultFee'] ?? 0.0).toDouble();
      }
      
      return 0.0;
    } catch (e) {
      debugPrint('Error getting gang fee: $e');
      return 0.0;
    }
  }
}
