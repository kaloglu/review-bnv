import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final winnersSubcollectionExistsProvider =
StreamProvider.autoDispose.family<bool, String>((ref, documentId) {
  try {
    final streamController = StreamController<bool>();

    // Add your asynchronous logic to check the subcollection here
    FirebaseFirestore.instance
        .collection('raffle')
        .doc(documentId)
        .collection('winners')
        .snapshots()
        .listen((snapshot) {
      final subcollectionExists = snapshot.docs.isNotEmpty;
      streamController.add(subcollectionExists);
    }, onError: (error) {
      // Handle any errors during the Firestore query
      if (kDebugMode) {
        print('Error checking subcollection: $error');
      }
      streamController.addError(error);
    });

    return streamController.stream;
  } catch (e) {
    // Handle any synchronous errors
    if (kDebugMode) {
      print('Error checking subcollection: $e');
    }
    return Stream.value(false);
  }
});

