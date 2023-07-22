import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/profile_model.dart';

final profileStreamProvider = StreamProvider.autoDispose<List<ProfileModel>>((ref) {
  // Reference to the Firestore collection
  User? user = FirebaseAuth.instance.currentUser;
  final firebasefirestore = FirebaseFirestore.instance.collection('users');

  // Check if the user is logged in before fetching data
  if (user == null) {
    return Stream.value([]); // Return an empty list if user is not logged in
  }

  // Filter the collection based on the current user's ID (UID)
  return firebasefirestore
      .where('uid', isEqualTo: user.uid) // Modify 'uid' to match your field name in Firestore
      .snapshots()
      .map((snapshot) {
    // Convert each document to a ProfileModel object
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return ProfileModel(
        fullname: data['fullname'],
        email: data['email'],
        phone: data['phone'],
        country: data['country'],
        city: data['city'],
        address: data['address'],
        profilepic: data['profilepic'],
        uid: doc.id,
      );
    }).toList();
  });
});
