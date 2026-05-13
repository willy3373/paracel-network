
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final snap = await FirebaseFirestore.instance.collection('agencies').get();
  for (var doc in snap.docs) {
    print('Agency: ${doc.data()['name']} | City: ${doc.data()['city']} | GangLine: ${doc.data()['gangLine']}');
  }
}
