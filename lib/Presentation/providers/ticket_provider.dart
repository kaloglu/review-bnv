import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Domain/models/ticket_model.dart';

final ticketStreamProvider =
    StreamProvider.autoDispose<List<TicketModel>>((ref) {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value([]);
  }

  final firebasefirestore = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('tickets');

  return firebasefirestore
      .orderBy('createDate',
          descending: true) // Order documents by createDate in descending order
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      DateTime createDate = (data['createDate'] as Timestamp).toDate();

      return TicketModel(
        createDate: createDate,
        earn: data['earn'],
        source: data['source'],
        remain: data['remain'],
        uid: doc.id,
      );
    }).toList();
  });
});
