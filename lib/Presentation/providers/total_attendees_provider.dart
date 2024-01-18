import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalAttendeesStreamProvider =
StreamProvider.family<QuerySnapshot, String>((ref, documentId) {
  return FirebaseFirestore.instance
      .collection('raffles')
      .doc(documentId)
      .collection('attendees')
      .snapshots();
});