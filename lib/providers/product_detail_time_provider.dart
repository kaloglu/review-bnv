import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

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