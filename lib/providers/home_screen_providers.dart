

 import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/enum_for_date.dart';
import '../models/product_model.dart';

ProductState getProductState(ProductModel product) {
    final currentDate = DateTime.now();

    if (currentDate.isBefore(product.startDate.toDate())) {
      return ProductState.StartDate;
    } else if (currentDate.isBefore(product.endDate.toDate())) {
      return ProductState.EndDate;
    } else if (currentDate.isBefore(product.inProgressDate.toDate())) {
      return ProductState.InProgress;
    } else {
      return ProductState.Done;
    }
  }

  String formatRemainingTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }



  //homescreenTimeProvider

  final remainingTimeProvider =
    StreamProvider.family<String, DateTime>((ref, startDate) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final currentDate = DateTime.now();
    final remainingDuration = startDate.difference(currentDate);

    if (remainingDuration.isNegative) {
      return 'Expired';
    } else {
      final hours = remainingDuration.inHours;
      final minutes =
          (remainingDuration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds =
          (remainingDuration.inSeconds % 60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
  }).startWith('Loading');
});