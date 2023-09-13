import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchTextNotifier extends StateNotifier<String> {
  SearchTextNotifier() : super('');

  void setSearchText(String searchText) {
    state = searchText;
  }
}

final searchTextProvider =
    StateNotifierProvider<SearchTextNotifier, String>((ref) {
  return SearchTextNotifier();
});