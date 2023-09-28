import 'dart:async';

import 'package:cihan_app/models/attendees_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enroll_model.dart';
final attendeesStreamProvider = StreamProvider.autoDispose<List<AttendeesModel>>((ref) {
  final firebasefirestore = FirebaseFirestore.instance;

  return firebasefirestore.collectionGroup('attendees').snapshots().map((attendeesSnapshot) {
    final attendeeList = attendeesSnapshot.docs.map((attendeeDoc) {
      final data = attendeeDoc.data();
      DateTime createDate = (data['createDate'] as Timestamp).toDate();

      return AttendeesModel(
        createDate: createDate,
        uid: attendeeDoc.id,
        productId: data['productId'], // Set the productId from the data
      );
    }).toList();

    return attendeeList;
  });
});

