import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalRemainProvider = StreamProvider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final ticketsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tickets');

    return ticketsCollection.snapshots().map((querySnapshot) {
      int totalSum = 0;

      final currentDate = DateTime.now();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expiryDateTimestamp = data['expiryDate'] as Timestamp;
        final int remain = data['remain'] ?? 0;

        if (expiryDateTimestamp != null) {
          final expiryDate = expiryDateTimestamp.toDate();
          if (expiryDate.isAfter(currentDate)) {
            totalSum += remain;
          }
        } else {
          totalSum += remain; // Handle cases where expiryDate is not set
        }
      }

      return totalSum.toString();
    });
  } else {
    return const Stream<String>.empty();
  }
});

