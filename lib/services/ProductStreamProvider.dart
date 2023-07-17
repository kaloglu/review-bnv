import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model.dart';


  final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
    // Reference to the Firestore collection
    final _firebasefirestore =
        FirebaseFirestore.instance.collection('raffles');

    // Return the stream of product documents
    return _firebasefirestore.snapshots().map((snapshot) {
      // Convert each document to a ProductModel object
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          startDate: data['startDate'],
        
        );
      }).toList();
    });
  });
