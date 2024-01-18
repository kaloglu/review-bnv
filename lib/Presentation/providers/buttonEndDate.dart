// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// final isButtonEnabledProvider = StreamProvider.family<bool, String>((ref, documentId) {
//   try {
//     return FirebaseFirestore.instance
//         .collection('raffles')
//         .doc(documentId)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.exists) {
//         Timestamp? startDate = snapshot.get('startDate');
//         Timestamp? endDate = snapshot.get('endDate');
//
//         if (startDate != null && endDate != null) {
//           DateTime now = DateTime.now();
//
//           // Calculate time difference in hours
//           int hoursDifference = endDate.toDate().difference(now).inHours;
//
//           return (now.isBefore(startDate.toDate()) || now.isAfter(endDate.toDate()))
//               ? false
//               : true;
//         }
//       }
//       return false; // or handle the case when the document doesn't exist
//     }).distinct(); // Ensure the stream only emits distinct values
//   } catch (error) {
//     print('Error checking endDate status: $error');
//     return Stream.value(false); // or handle the error case appropriately
//   }
// });
