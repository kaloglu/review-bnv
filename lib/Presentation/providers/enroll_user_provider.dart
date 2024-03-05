import 'package:cihan_app/Presentation/screens/product_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../lang.dart';
import '../../main.dart';
import '../constants/text_styles.dart';

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
      final userDocSnapshot = await userDocRef.get();
      final userAddress = userDocSnapshot.data()?['address'];
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

      // First i want to check for address

      if (userAddress == null || (userAddress as String).isEmpty) {
        showOverlayNotification((context) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading: SizedBox.fromSize(
                  size: const Size(40, 40),
                  child: ClipOval(child: Container(color: Colors.black)),
                ),
                title: const Text('Address Required'),
                subtitle: const Text('Please update your address to proceed.'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => OverlaySupportEntry.of(context)?.dismiss(),
                ),
              ),
            ),
          );
        },
            duration: const Duration(
                milliseconds: 4000)); // Adjust duration as needed
        return; // Exit the function as we cannot proceed without an address
      }

      if (userEnrollmentCount >= maxAttendedByUser) {
        showDialogWithoutContext(
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              // This makes the dialog square
              borderRadius: BorderRadius.circular(0),
            ),

            backgroundColor:
                Colors.white, // Make AlertDialog background transparent
            content: Column(
              mainAxisSize: MainAxisSize.min, // Use min size
              children: <Widget>[
                Container(
                  width: 100, // Diameter of the circle
                  height:
                      100, // Diameter of the circle, make sure width and height are equal to get a perfect circle
                  decoration: const BoxDecoration(
                    color: Colors.blue, // Your desired background color
                    shape: BoxShape.circle, // This makes the container a circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Adjust padding to avoid the image touching the edges
                    child: ClipOval(
                      // Clip the image to Oval shape to fit the circle container
                      child: Image.asset(
                        'assets/dialogueTicket.png',
                        color: Colors.black,
                        // fit: BoxFit.cover, // This ensures the image covers the container space, adjust as needed
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Bilgi',
                    style: kMediumTextStyle.copyWith(
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 10), // Space between icon and text
                const Text(AppStrings
                    .youHaveReachedTheMaximumAllowedEnrollmentsForThisRaffle), // Your message
              ],
            ),

            actions: <Widget>[
              Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 16.5)),
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0XFF87ceeb)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      AppStrings.okay,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        //Fluttertoast.showToast(msg: AppStrings.youHaveReachedTheMaximumAllowedEnrollmentsForThisRaffle);

        // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        //   const SnackBar(content: Text(AppStrings
        //       .youHaveReachedTheMaximumAllowedEnrollmentsForThisRaffle)),
        // );
      }

      if (userEnrollmentCount >= maxAttendee) {
        showDialogWithoutContext(
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              // This makes the dialog square
              borderRadius: BorderRadius.circular(0),
            ),

            backgroundColor:
                Colors.white, // Make AlertDialog background transparent
            content: Column(
              mainAxisSize: MainAxisSize.min, // Use min size
              children: <Widget>[
                Container(
                  width: 100, // Diameter of the circle
                  height:
                      100, // Diameter of the circle, make sure width and height are equal to get a perfect circle
                  decoration: const BoxDecoration(
                    color: Colors.blue, // Your desired background color
                    shape: BoxShape.circle, // This makes the container a circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8.0), // Adjust padding to avoid the image touching the edges
                    child: ClipOval(
                      // Clip the image to Oval shape to fit the circle container
                      child: Image.asset(
                        'assets/dialogueTicket.png',
                        color: Colors.black,
                        // fit: BoxFit.cover, // This ensures the image covers the container space, adjust as needed
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Bilgi',
                    style: kMediumTextStyle.copyWith(
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 10), // Space between icon and text
                const Text(AppStrings
                    .theMaximumNumberOfAttendeesForThisRaffleHasBeenReached), // Your message
              ],
            ),

            actions: <Widget>[
              Center(
                child: SizedBox(
                  width: 150,
                  child: TextButton(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 16.5)),
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0XFF87ceeb)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      AppStrings.okay,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        //  Fluttertoast.showToast(msg: AppStrings.theMaximumNumberOfAttendeesForThisRaffleHasBeenReached);

        // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        //   const SnackBar(content: Text(AppStrings
        //       .theMaximumNumberOfAttendeesForThisRaffleHasBeenReached)),
        // );

        return;
      }
      if (userEnrollmentCount >= maxAttendedByUser ||
          userEnrollmentCount >= maxAttendee) {
        showDialogWithoutContext(
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              // This makes the dialog square
              borderRadius: BorderRadius.circular(0),
            ),

            backgroundColor:
                Colors.white, // Make AlertDialog background transparent
            title: const Text('Bilgi'),
            content: const Text('Exceed enrollment limit'),
            actions: <Widget>[
              SizedBox(
                width: 150,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.okay),
                ),
              ),
            ],
          ),
        );

        // Fluttertoast.showToast(msg: 'Exceed enrollment limit');
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

          showDialogWithoutContext(
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                // This makes the dialog square
                borderRadius: BorderRadius.circular(0),
              ),

              backgroundColor:
                  Colors.white, // Make AlertDialog background transparent
              content: Column(
                mainAxisSize: MainAxisSize.min, // Use min size
                children: <Widget>[
                  Container(
                    width: 100, // Diameter of the circle
                    height:
                        100, // Diameter of the circle, make sure width and height are equal to get a perfect circle
                    decoration: const BoxDecoration(
                      color: Colors.blue, // Your desired background color
                      shape:
                          BoxShape.circle, // This makes the container a circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          8.0), // Adjust padding to avoid the image touching the edges
                      child: ClipOval(
                        // Clip the image to Oval shape to fit the circle container
                        child: Image.asset(
                          'assets/dialogueTicket.png',
                          color: Colors.black,
                          // fit: BoxFit.cover, // This ensures the image covers the container space, adjust as needed
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Bilgi',
                      style: kMediumTextStyle.copyWith(
                        fontWeight: FontWeight.w900,
                      )),
                  const SizedBox(height: 10), // Space between icon and text
                  const Text(AppStrings.enrolledSuccessfully), // Your message
                ],
              ),

              actions: <Widget>[
                Center(
                  child: SizedBox(
                    width: 150,
                    child: TextButton(
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all(
                            const TextStyle(fontSize: 16.5)),
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0XFF87ceeb)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        AppStrings.okay,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          //Fluttertoast.showToast(msg: AppStrings.enrolledSuccessfully);

          // ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
          //   const SnackBar(content: Text(AppStrings.enrolledSuccessfully)),
          // );

          return;
        }
      }
      showDialogWithoutContext(
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            // This makes the dialog square
            borderRadius: BorderRadius.circular(0),
          ),

          backgroundColor:
              Colors.white, // Make AlertDialog background transparent
          content: Column(
            mainAxisSize: MainAxisSize.min, // Use min size
            children: <Widget>[
              Container(
                width: 100, // Diameter of the circle
                height:
                    100, // Diameter of the circle, make sure width and height are equal to get a perfect circle
                decoration: const BoxDecoration(
                  color: Colors.blue, // Your desired background color
                  shape: BoxShape.circle, // This makes the container a circle
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                      8.0), // Adjust padding to avoid the image touching the edges
                  child: ClipOval(
                    // Clip the image to Oval shape to fit the circle container
                    child: Image.asset(
                      'assets/dialogueTicket.png',
                      color: Colors.black,
                      // fit: BoxFit.cover, // This ensures the image covers the container space, adjust as needed
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('Bilgi',
                  style: kMediumTextStyle.copyWith(
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(height: 10), // Space between icon and text
              const Text(AppStrings.notEnoughTicketsToEnroll), // Your message
            ],
          ),

          actions: <Widget>[
            Center(
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 16.5)),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0XFF87ceeb)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showOverlayNotification((context) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: SafeArea(
                          child: ListTile(
                            leading: SizedBox.fromSize(
                                size: const Size(40, 40),
                                child: ClipOval(
                                    child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors
                                        .blue, // Your desired background color
                                    shape: BoxShape
                                        .circle, // This makes the container a circle
                                  ),
                                  child: Image.asset('assets/dialogueTicket.png'),
                                ))),
                            title: Text(
                              'Ohh No Tickets',
                              style: kMediumTextStyle.copyWith(
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: const Text(
                                'If you watch the ad then you will get tickets'),
                            trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  OverlaySupportEntry.of(context)?.dismiss();

                                  // here i want to implement the shake method
                                }),
                          ),
                        ),
                      );
                    }, duration: const Duration(milliseconds: 400000));
                  },
                  child: const Text(
                    AppStrings.okay,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      // Fluttertoast.showToast(msg: AppStrings.notEnoughTicketsToEnroll);
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

void showDialogWithoutContext(
    {required Widget Function(BuildContext) builder}) {
  if (navigatorKey.currentState == null) return;

  showDialog(
    context: navigatorKey.currentState!.overlay!.context,
    builder: builder,
  );
}
