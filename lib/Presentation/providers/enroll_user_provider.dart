import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/Text.dart';



final enrollmentProvider =
    StateNotifierProvider<EnrollmentController, EnrollmentState>((ref) {
  return EnrollmentController();
});

class EnrollmentController extends StateNotifier<EnrollmentState> {
  EnrollmentController() : super(EnrollmentState.initial());

  Future<void> enrollUser(documentId) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      state = EnrollmentState(isEnrollmentInProgress: true); // Update state

      final firestore = FirebaseFirestore.instance;

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      final productDocRef = firestore.collection('raffles').doc(documentId);

      final userTicketsCollectionRef = userDocRef.collection('tickets');
      final attendeeCollectionRef = productDocRef.collection('attendees');

      final userEnrollmentQuerySnapshot = await attendeeCollectionRef
          .where('userId', isEqualTo: user?.uid)
          .get();
      final userEnrollmentCount = userEnrollmentQuerySnapshot.docs.length;
      final productSnapshot = await FirebaseFirestore.instance
          .collection('raffles')
          .doc(documentId)
          .get();
      final requiredTickets = productSnapshot['requiredTickets'] as int;
      final maxAttendedByUser =
          productSnapshot['rules']?['maxAttendByUser'] as int;
      final maxAttendee = productSnapshot['rules']?['maxAttendee'] as int;
      if (userEnrollmentCount >= maxAttendedByUser) {
        Fluttertoast.showToast(msg: AppStrings.youHaveReachedTheMaximumAllowedEnrollmentsForThisRaffle);

        // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        //   const SnackBar(content: Text(AppStrings
        //       .youHaveReachedTheMaximumAllowedEnrollmentsForThisRaffle)),
        // );

      }

      if (userEnrollmentCount >= maxAttendee) {
        Fluttertoast.showToast(msg: AppStrings.theMaximumNumberOfAttendeesForThisRaffleHasBeenReached);

        // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        //   const SnackBar(content: Text(AppStrings
        //       .theMaximumNumberOfAttendeesForThisRaffleHasBeenReached)),
        // );

        return;
      }
      if (userEnrollmentCount >= maxAttendedByUser ||
          userEnrollmentCount >= maxAttendee) {
        Fluttertoast.showToast(msg: 'Exceed enrollment limit');
        // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        //   const SnackBar(content: Text('Exceed enrollment limit')),
        // );

      }


      final now = DateTime.now();
      QuerySnapshot userTicketsQuerySnapshot = await userTicketsCollectionRef
          .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('expiryDate')
          .get();

      int remainingRequiredTickets = requiredTickets;
      int totalRemainingTickets = 0;

      // Sort user tickets by expiryDate in ascending order
      userTicketsQuerySnapshot.docs.sort((a, b) {
        final expiryDateA = a['expiryDate'] as Timestamp;
        final expiryDateB = b['expiryDate'] as Timestamp;
        return expiryDateA.compareTo(expiryDateB);
      });

      for (final userTicket in userTicketsQuerySnapshot.docs) {
        final userTicketsData = userTicket.data() as Map<String, dynamic>?;
        final remainTickets = userTicketsData?['remain'] as int;

        totalRemainingTickets += remainTickets;

        if (totalRemainingTickets >= remainingRequiredTickets) {
          // There are enough tickets collectively in the documents

          // Enroll the user successfully

          // Deduct requiredTickets from each document
          for (final userTicket in userTicketsQuerySnapshot.docs) {
            final userTicketsData = userTicket.data() as Map<String, dynamic>?;
            final remainTickets = userTicketsData?['remain'] as int;

            if (remainTickets > 0) {
              final deductedTickets = remainTickets >= remainingRequiredTickets
                  ? remainingRequiredTickets
                  : remainTickets;

              await userTicket.reference
                  .update({'remain': remainTickets - deductedTickets});
              remainingRequiredTickets -= deductedTickets;

              if (remainingRequiredTickets == 0) {
                break; // No more tickets required, exit the loop
              }
            }
          }

          // Continue with the rest of your enrollment logic
          final attendeeCollectionRef = FirebaseFirestore.instance
              .collection('raffles')
              .doc(documentId)
              .collection('attendees');
          final attendeeCountSnapshot = await attendeeCollectionRef.get();
          final attendeeCount = attendeeCountSnapshot.docs.length;

          final attendeeData = {
            'userId': user?.uid,
            'createDate': FieldValue.serverTimestamp(),
            'raffleId': documentId,
            'number': attendeeCount,
          };

          await attendeeCollectionRef.add(attendeeData);

          final enrollmentCollectionRef = userDocRef.collection('enroll');
          final enrollmentQuerySnapshot = await enrollmentCollectionRef
              .where('raffleid', isEqualTo: documentId)
              .get();

          if (enrollmentQuerySnapshot.docs.isNotEmpty) {
            final enrollmentDoc = enrollmentQuerySnapshot.docs.first;
            final currentEnrollmentCount =
                enrollmentDoc['enrollmentCount'] as int;
            final newEnrollmentCount = currentEnrollmentCount + 1;

            await enrollmentDoc.reference
                .update({'enrollmentCount': newEnrollmentCount});
          } else {
            final productData = productSnapshot.data();
            final productTitle = productData?['title'] ?? '';
            final productDescription = productData?['description'] ?? '';
            final productImage = productData?['image'] ?? '';

            final enrollData = {
              'ticketid': userTicketsQuerySnapshot.docs.first.id,
              'raffleid': documentId,
              'enrollDate': FieldValue.serverTimestamp(),
              'title': productTitle,
              'description': productDescription,
              'image': productImage,
              'enrollmentCount': 1,
            };

            await enrollmentCollectionRef.add(enrollData);
          }

          Fluttertoast.showToast(msg: AppStrings.enrolledSuccessfully);

          // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          //   const SnackBar(content: Text(AppStrings.enrolledSuccessfully)),
          // );


          return;
        }
      }
      Fluttertoast.showToast(msg: AppStrings.notEnoughTicketsToEnroll);
      // ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(
      //   const SnackBar(content: Text(AppStrings.notEnoughTicketsToEnroll)),
      // );

    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    } finally {
      // Ensure state is reset even in case of errors
      state = EnrollmentState.initial();
    }
  }
}

class EnrollmentState {
  EnrollmentState({
    this.isEnrollmentInProgress = false,
  });

  final bool isEnrollmentInProgress;

  static EnrollmentState initial() => EnrollmentState();
}

// void _enrollUser() async {
//   final user = FirebaseAuth.instance.currentUser;
//
//   if (user != null) {
//     setState(() {
//       isEnrollmentInProgress = true;
//     });
//   }
//
//   try {
//     final firestore = FirebaseFirestore.instance;
//
//     final userDocRef = FirebaseFirestore.instance.collection('users').doc(user?.uid);
//     final productDocRef = firestore.collection('raffles').doc(widget.documentId);
//
//     final userTicketsCollectionRef = userDocRef.collection('tickets');
//     final attendeeCollectionRef = productDocRef.collection('attendees');
//
//     final userEnrollmentQuerySnapshot = await attendeeCollectionRef
//         .where('userId', isEqualTo: user?.uid)
//         .get();
//     final userEnrollmentCount = userEnrollmentQuerySnapshot.docs.length;
//     final productSnapshot = await FirebaseFirestore.instance.collection('raffles').doc(widget.documentId).get();
//     final requiredTickets = productSnapshot['requiredTickets'] as int;
//     final maxAttendedByUser = productSnapshot['rules']?['maxAttendByUser'] as int;
//     final maxAttendee = productSnapshot['rules']?['maxAttendee'] as int;
//     if (userEnrollmentCount >= maxAttendedByUser) {
//
//
//       if(!mounted){
//         return;
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text(AppStrings.youHaveReachedTheMaximumAllowedEnrollmentsForThisRaffle)),
//       );
//
//
//     }
//
//     if (userEnrollmentCount >= maxAttendee) {
//       if(!mounted){
//         return;
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text(
//             AppStrings.theMaximumNumberOfAttendeesForThisRaffleHasBeenReached)),
//       );
//       return;
//     }
//     // if (userEnrollmentCount >= maxAttendedByUser || userEnrollmentCount >= maxAttendee) {
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(content: Text("Exceeded enrollment limit")),
//     //   );
//     //   return;
//     // }
//
//     final now = DateTime.now();
//     QuerySnapshot userTicketsQuerySnapshot = await userTicketsCollectionRef
//         .where('expiryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
//         .orderBy('expiryDate')
//         .get();
//
//     int remainingRequiredTickets = requiredTickets;
//     int totalRemainingTickets = 0;
//
//     // Sort user tickets by expiryDate in ascending order
//     userTicketsQuerySnapshot.docs.sort((a, b) {
//       final expiryDateA = a['expiryDate'] as Timestamp;
//       final expiryDateB = b['expiryDate'] as Timestamp;
//       return expiryDateA.compareTo(expiryDateB);
//     });
//
//     for (final userTicket in userTicketsQuerySnapshot.docs) {
//       final userTicketsData = userTicket.data() as Map<String, dynamic>?;
//       final remainTickets = userTicketsData?['remain'] as int ?? 0;
//
//       totalRemainingTickets += remainTickets;
//
//       if (totalRemainingTickets >= remainingRequiredTickets) {
//         // There are enough tickets collectively in the documents
//         final newRemainingTickets = totalRemainingTickets - remainingRequiredTickets;
//
//         // Enroll the user successfully
//
//         // Deduct requiredTickets from each document
//         for (final userTicket in userTicketsQuerySnapshot.docs) {
//           final userTicketsData = userTicket.data() as Map<String, dynamic>?;
//           final remainTickets = userTicketsData?['remain'] as int;
//
//           if (remainTickets > 0) {
//             final deductedTickets = remainTickets >= remainingRequiredTickets
//                 ? remainingRequiredTickets
//                 : remainTickets;
//
//             await userTicket.reference.update({'remain': remainTickets - deductedTickets});
//             remainingRequiredTickets -= deductedTickets;
//
//             if (remainingRequiredTickets == 0) {
//               break; // No more tickets required, exit the loop
//             }
//           }
//         }
//
//         // Continue with the rest of your enrollment logic
//         final attendeeCollectionRef = FirebaseFirestore.instance.collection('raffles').doc(widget.documentId).collection('attendees');
//         final attendeeCountSnapshot = await attendeeCollectionRef.get();
//         final attendeeCount = attendeeCountSnapshot.docs.length;
//
//         final attendeeData = {
//           'userId': user?.uid,
//           'createDate': FieldValue.serverTimestamp(),
//           'raffleId': widget.documentId,
//           'number': attendeeCount,
//         };
//
//         await attendeeCollectionRef.add(attendeeData);
//
//         final enrollmentCollectionRef = userDocRef.collection('enroll');
//         final enrollmentQuerySnapshot = await enrollmentCollectionRef
//             .where('raffleid', isEqualTo: widget.documentId)
//             .get();
//
//         if (enrollmentQuerySnapshot.docs.isNotEmpty) {
//           final enrollmentDoc = enrollmentQuerySnapshot.docs.first;
//           final currentEnrollmentCount = enrollmentDoc['enrollmentCount'] as int;
//           final newEnrollmentCount = currentEnrollmentCount + 1;
//
//           await enrollmentDoc.reference.update({'enrollmentCount': newEnrollmentCount});
//         } else {
//           final productData = productSnapshot.data();
//           final productTitle = productData?['title'] ?? '';
//           final productDescription = productData?['description'] ?? '';
//           final productImage = productData?['image'] ?? '';
//
//           final enrollData = {
//             'ticketid': userTicketsQuerySnapshot.docs.first.id,
//             'raffleid': widget.documentId,
//             'enrollDate': FieldValue.serverTimestamp(),
//             'title': productTitle,
//             'description': productDescription,
//             'image': productImage,
//             'enrollmentCount': 1,
//           };
//
//           await enrollmentCollectionRef.add(enrollData);
//         }
//         if(!mounted){
//           return;
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text(AppStrings.enrolledSuccessfully)),
//         );
//
//         return;
//       }
//     }
//     if(!mounted){
//       return;
//     }
//     // If the loop completes, there are not enough tickets
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text(AppStrings.notEnoughTicketsToEnroll)),
//     );
//   } catch (e) {
//     if (kDebugMode) {
//       print('Error: $e');
//     }
//
//
//
//
//
//   }
//   finally{
//     //Set the isEnrollmentInProgress to false
//     setState(() {
//       isEnrollmentInProgress = false;
//     });
//   }
// }
