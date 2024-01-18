import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchTextNotifier extends StateNotifier<String> {
  SearchTextNotifier() : super('');

  void setSearchText(String searchText) {
    if (kDebugMode) {
      print('Search text: $searchText');
    }
    state = searchText;
  }

}

final searchTextProvider =
    StateNotifierProvider<SearchTextNotifier, String>((ref) {
  return SearchTextNotifier();
});