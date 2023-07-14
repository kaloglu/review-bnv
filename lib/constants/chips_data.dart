import 'package:flutter/material.dart';

import '../models/product_model.dart';

List<String> getAvailableChips(List<ProductModel> data) {
  final Set<String> uniqueCategories =
      data.map((product) => product.category).toSet();
  return uniqueCategories.toList();
}

final categoryIconMap = {
  'Working': Icons.work,
  'Music': Icons.headphones,
  'Gaming': Icons.gamepad,
  'Cooking & Eating': Icons.restaurant,
};

final categoryColorMap = {
  'Working': Colors.red,
  'Music': Colors.blue,
  'Gaming': Colors.green,
  'Cooking & Eating': Colors.pink,
};
