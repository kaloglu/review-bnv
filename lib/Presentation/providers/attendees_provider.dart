import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Domain/models/attendees_model.dart';


final attendeesStreamProvider =
    StreamProvider.autoDispose<List<AttendeesModel>>((ref) {
  final firebasefirestore = FirebaseFirestore.instance;

  return firebasefirestore
      .collectionGroup('attendees')
      .snapshots()
      .map((attendeesSnapshot) {
    final attendeeList = attendeesSnapshot.docs.map((attendeeDoc) {
      final data = attendeeDoc.data();

      DateTime createDate = (data['createDate'] as Timestamp).toDate();

      return AttendeesModel(
        createDate: createDate,
        //deviceToken: data['deviceToken'],
        uid: attendeeDoc.id,
        raffleId: data['raffleId'], // Set the raffleId from the data
      );
    }).toList();

    return attendeeList;
  });
});
