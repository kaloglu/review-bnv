import 'package:cihan_app/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_info_model.dart';
import '../models/rules_model.dart';

final productInfoImagesStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final stream =
      firestore.collection('raffles').snapshots().map((querySnapshot) {
    return querySnapshot.docs.map((documentSnapshot) {
      final productInfo = documentSnapshot.data()?['productInfo'];
      if (productInfo != null) {
        final images = productInfo['images'] as List<dynamic>;
        return {
          'id': documentSnapshot.id,
          'images': images,
        };
      } else {
        return {
          'id': documentSnapshot.id,
          'images': [],
        };
      }
    }).toList();
  });
  return stream;
});

final productsStreamProvider =
    StreamProvider.autoDispose<List<ProductModel>>((ref) {
  // Reference to the Firestore collection

  final firebasefirestore = FirebaseFirestore.instance.collection('raffles');

  // Return the stream of product documents
  return firebasefirestore.snapshots().map((snapshot) {
    // Convert each document to a ProductModel object
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Convert the productInfo field to a Map<String, dynamic>
      final productInfoData = data['productInfo'] as Map<String, dynamic>;

      // Create a ProductInfo object using the ProductInfo.fromJson constructor
      final productInfo = ProductInfo.fromJson(productInfoData);

      final rulesInfoData = data['rules'] as Map<String, dynamic>;

      // Create a ProductInfo object using the ProductInfo.fromJson constructor
      final rules = Rules.fromJson(rulesInfoData);
      return ProductModel(
        id: doc.id,
        title: data['title'],
        description: data['description'],
        image: data['image'],
        startDate: data['startDate'],
        endDate: data['endDate'],
        resultDate: data['resultDate'],
        requiredTickets: data['requiredTickets'],
        category: data['category'],







        productInfo: productInfo,
        rules: rules,
      );
    }).toList();
  });
});
