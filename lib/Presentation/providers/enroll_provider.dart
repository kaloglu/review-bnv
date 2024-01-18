import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Domain/models/enroll_model.dart';



final enrollStreamProvider =
    StreamProvider.autoDispose<List<EnrollModel>>((ref) {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value([]);
  }

  final firebasefirestore = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('enroll');

  return firebasefirestore.snapshots().map((snapshot) {
    final ticketList = snapshot.docs.map((doc) {
      final data = doc.data();
      DateTime enrollDate = (data['enrollDate'] as Timestamp).toDate();

      return EnrollModel(
        enrollDate: enrollDate,
        ticketid: data['ticketid'],
        raffleid: data['raffleid'],
        uid: doc.id,
        title: data['title'],
        description: data['description'],
        enrollmentCount: data['enrollmentCount'],
        image: data['image'],
      );
    }).toList();

    return ticketList;
  });
});
