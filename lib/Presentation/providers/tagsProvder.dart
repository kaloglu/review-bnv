import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagsProvider = FutureProvider<List<String>>((ref) async {
  var tags = <String>[]; // Ensure tags is of type List<String>

  // Fetch all documents from the "raffles" collection
  var querySnapshot = await FirebaseFirestore.instance.collection("raffles").get();

  // Extract tags from each document
  for (var document in querySnapshot.docs) {
    var documentTags = document.data()['tags'] as List;
    tags.addAll(documentTags.map((tag) => tag.toString())); // Convert each tag to a String
  }

  // Remove duplicates to get unique tags
  tags = tags.toSet().toList();
  return tags;
});

