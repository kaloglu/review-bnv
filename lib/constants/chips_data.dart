  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';
import '../presentation/screens/home_screen.dart';














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