import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LuckyDraw {
  Future<void> performLuckyDrawBasedOnCount(String raffleId) async {
    try {
      // Reference to the raffle document.
      final raffleDocument =
      FirebaseFirestore.instance.collection('raffles').doc(raffleId);

      // Fetch the Firestore document data.
      final DocumentSnapshot raffleSnapshot = await raffleDocument.get();
      final data = raffleSnapshot.data() as Map<String, dynamic>;

      // Check if the 'productInfo' map exists.
      if (data.containsKey('productInfo') && data['productInfo'] is Map) {
        final productInfo = data['productInfo'] as Map<String, dynamic>;

        // Check if the 'count' field exists in the 'productInfo' map.
        if (productInfo.containsKey('count')) {
          final count = productInfo['count'] as int;

          // Check if 'count' is greater than or equal to 1.
          if (count >= 1) {
            // Call the performLuckyDraw method the specified number of times.
            for (int i = 0; i < count; i++) {
              await performLuckyDraw(raffleId);
            }

            // After performing lucky draws, check if the 'winners' subcollection exists.
            final winnersCollection = raffleDocument.collection('winners');
            final winnersQuery = await winnersCollection.get();

            // If the 'winners' subcollection exists and its size matches the 'count' value, set the 'resultDate' field.
            if (winnersQuery.size == count) {
              await raffleDocument.update({
                'resultDate': DateTime.now(),
              });
            }
          } else {
            if (kDebugMode) {
              print('Count is less than 1. No lucky draws to perform.');
            }
          }
        } else {
          if (kDebugMode) {
            print('No "count" field found in "productInfo" map.');
          }
        }
      } else {
        if (kDebugMode) {
          print('No "productInfo" map found in Firestore document.');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in fetching count from Firestore: $error');
      }
    }
  }

  Future<void> performLuckyDraw(String raffleId) async {

    try {
      // Reference to the raffle document and its attendees subcollection.
      final raffleDocument =
      FirebaseFirestore.instance.collection('raffles').doc(raffleId);
      final attendeesCollection = raffleDocument.collection('attendees');

      // Get all the documents in the attendees collection.
      final QuerySnapshot attendeesSnapshot = await attendeesCollection.get();

      // Get the attendees' documents and shuffle them.
      final List<QueryDocumentSnapshot> attendeesDocs = attendeesSnapshot.docs;

      // Initialize a variable to keep track of the number of attempts.
      int attempts = 0;
      QueryDocumentSnapshot luckyWinner;

      // Keep performing the lucky draw until a different winner is found.
      while (true) {
        attendeesDocs.shuffle();
        if (attempts < attendeesDocs.length) {
          luckyWinner = attendeesDocs[attempts];
          final luckyWinnerData = luckyWinner.data();

          // Ensure luckyWinnerData is not null before sending notifications.
          if (luckyWinnerData != null) {
            // Check the type of luckyWinnerData before accessing the userId and raffleId properties.
            if (luckyWinnerData is Map<String, dynamic>) {
              final userId = luckyWinnerData['userId'] as String;
              final deviceToken = luckyWinnerData['deviceToken'] as String?;
              final raffleId = luckyWinnerData['raffleId'];
              if (kDebugMode) {
                print('Lucky winner details: $luckyWinnerData');
              }

              // Check if the user has already won in the raffle
              final winnersCollection = raffleDocument.collection('winners');
              final previousWinnersQuery = await winnersCollection
                  .where('userId', isEqualTo: userId)
                  .get();
              if (previousWinnersQuery.docs.isEmpty) {
                // Proceed with notifying the winner
                await winnersCollection.add({
                  'deviceToken': deviceToken,
                  'raffleId': raffleId,
                  'userId': userId,
                });

                // Send a push notification to the lucky winner using Firebase Cloud Messaging (FCM).
                // ... (code to send notification) ...

                break; // Exit the loop when a new winner is found.
              } else {
                if (kDebugMode) {
                  print('User $userId has already won in this raffle.');
                }
              }
            } else {
              if (kDebugMode) {
                print('Lucky winner data is not in the expected format.');
              }
            }
          } else {
            if (kDebugMode) {
              print('Lucky winner data is null.');
            }
          }
          attempts++;
        } else {
          if (kDebugMode) {
            print('Not enough unique winners found within the attendees.');
          }
          break; // Exit the loop when no unique winners are found.
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error in creating documents: $error');
      }
    }
  }


}
