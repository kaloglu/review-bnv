import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../../Domain/models/product_model.dart';
import '../constants/enum_for_date.dart';

ProductState getProductState(ProductModel product) {
  final currentDate = DateTime.now();

  if (currentDate.isBefore(product.startDate.toDate())) {
    return ProductState.startDate;
  } else if (currentDate.isBefore(product.endDate.toDate())) {
    return ProductState.endDate;

  //else if (currentDate.isBefore(product.resultDate.toDate()))
  //{
    //return ProductState.resultDate;
  } else {
    return ProductState.done;
  }
}

String formatRemainingTime(Duration duration) {
  final hours = duration.inHours;
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

//homescreenTimeProvider






final remainingTimeProvider = StreamProvider.family<String, DateTime>((ref, startDate) {
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final currentDate = DateTime.now();
    final remainingDuration = startDate.difference(currentDate);

    if (remainingDuration.isNegative) {
      return '';
    } else {
      final days = remainingDuration.inDays;
      final hours = remainingDuration.inHours % 24;
      final minutes = remainingDuration.inMinutes % 60;
      final seconds = remainingDuration.inSeconds % 60;

      if (days > 0) {
        final dateFormat = DateFormat('dd.MMM.yy');
        return dateFormat.format(startDate);
      } else if (hours > 0) {
        return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else if (minutes > 0) {
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        return '${seconds.toString().padLeft(2, '0')} sec';
      }
    }
  }).startWith('Loading');
});

