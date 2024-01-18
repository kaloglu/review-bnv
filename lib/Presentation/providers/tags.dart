import 'package:cihan_app/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
//
// final rafflesCollectionProvider = StreamProvider<List<ProductModel>>((ref) {
//   final firestore = FirebaseFirestore.instance;
//   final rafflesCollection = firestore.collection('raffles');
//   return rafflesCollection.snapshots().map((snapshot) {
//     return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
//   });
// });

final rafflesCollectionProvider = StreamProvider<List<ProductModel>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final rafflesCollection = firestore.collection('raffles');
  return rafflesCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList();
  });
});




// final firestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });
//
// final rafflesCollectionProvider =
// Provider<CollectionReference>((ref) => ref.watch(firestoreProvider).collection('raffles'));
//
// final tagsProvider = FutureProvider<Set<String>>((ref) async {
//   final collection = ref.watch(rafflesCollectionProvider);
//   final snapshot = await collection.get();
//   Set<String> tags = {};
//   snapshot.docs.forEach((doc) {
//     final docTags = doc.get('tags') as List?;
//     if (docTags != null) {
//       tags.addAll(docTags.cast<String>());
//     }
//   });
//   return tags;
// });
//
// final selectedTagProvider = StateProvider<String?>((ref) => null);
//
// final filteredRafflesProvider = FutureProvider<List<DocumentSnapshot<Object?>>>(
//       (ref) async {
//     final collection = ref.watch(rafflesCollectionProvider);
//     final selectedTag = ref.watch(selectedTagProvider);
//
//     final querySnapshot = await collection
//         .where('tags', arrayContains: selectedTag)
//         .get();
//
//     return querySnapshot.docs;
//   },
// );




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

final selectedTagsProvider = ChangeNotifierProvider<SelectedTagsProvider>((ref) => SelectedTagsProvider());
