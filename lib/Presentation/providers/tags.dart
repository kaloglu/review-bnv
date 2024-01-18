import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../Domain/models/product_model.dart';

final rafflesCollectionProvider = StreamProvider<List<ProductModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final rafflesCollection = firestore.collection('raffles');
  return rafflesCollection.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();
  });
});

class SelectedTagsProvider extends ChangeNotifier {
  String _selectedTags = '';

  String get selectedTags => _selectedTags;

  void toggleTag(String tag) {
    if (_selectedTags == tag) {
      // If the selected tag is the same, clear it
      _selectedTags = '';
    } else {
      // If a new tag is selected, clear the existing one and set the new one
      _selectedTags = tag;
    }

    // Notify listeners to update the UI
    notifyListeners();
  }
}

final selectedTagsProvider = ChangeNotifierProvider<SelectedTagsProvider>(
    (ref) => SelectedTagsProvider());
