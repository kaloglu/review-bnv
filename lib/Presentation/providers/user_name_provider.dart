import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final usernamesProvider = StreamProvider.family<List<String>, String>((ref, documentId) {
  Stream<List<String>> usernamesStream = FirebaseFirestore.instance
      .collection('raffles')
      .doc(documentId) // Provide your raffle ID
      .collection('winners')
      .snapshots()
      .asyncMap((winnersQuery) async {
    List<String> usernames = [];


    for (QueryDocumentSnapshot winnerDocument in winnersQuery.docs) {
      String userId = winnerDocument['userId'];

      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        String username = userSnapshot['fullname'];
        usernames.add(username);
      } else {
        usernames.add('User not found');
      }
    }

    return usernames;
  });

  return usernamesStream;
});















// final usernamesProvider = FutureProvider.family<List<String>, String>((ref, documentId) async {
//   List<String> usernames = [];
//
//   // Reference to the "winners" subcollection
//   QuerySnapshot winnersQuery = await FirebaseFirestore.instance
//       .collection('raffles')
//       .doc(documentId) // Provide your raffle ID
//       .collection('winners')
//       .get();
//
//   for (QueryDocumentSnapshot winnerDocument in winnersQuery.docs) {
//     String userId = winnerDocument['userId'];
//
//     // Reference to the user's document in the "users" collection
//     DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
//
//     DocumentSnapshot userSnapshot = await userRef.get();
//
//     if (userSnapshot.exists) {
//       String username = userSnapshot['fullname'];
//       usernames.add(username);
//     } else {
//       usernames.add('User not found');
//     }
//   }
//
//   return usernames;
// });










