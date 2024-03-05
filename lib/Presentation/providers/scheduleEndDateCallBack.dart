

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'lucky_draw.dart';



bool _adLoading = false;
Timer? _loadingTimer;
bool _timerActive = false;
int newTicketCount = 0;
bool luckyDrawExecuted = false;
StreamController<bool> buttonEnabledController = StreamController();

//late StreamSubscription streamSubscription;
String status = 'Initial Status';

bool isEndDateReached() {
  final now = DateTime.now();
  return endDate != null && now.isAfter(endDate!);
}

// DateTime? resultDate;
late final String remainingTime;
void scheduleEndDateCallback(DateTime endDate, String documentId) async {
  final currentTime = DateTime.now();

  // Check if the end date has already passed
  if (endDate.isBefore(currentTime)) {
    // Check if winners exist in the 'winners' collection
    final winnersCollection = FirebaseFirestore.instance
        .collection('raffles')
        .doc(documentId)
        .collection('winners');
    final winnersSnapshot = await winnersCollection.get();

    if (winnersSnapshot.docs.isNotEmpty) {
      // Winners exist, do not execute the LuckyDraw class
      return;
    }

    // Winners do not exist, call the performLuckyDraw function
    LuckyDraw().performLuckyDrawBasedOnCount(documentId);
  }
}

 DateTime? startDate;
 DateTime? endDate;
void fetchStartAndEndDates(String documentId) async {
  final productDocRef = FirebaseFirestore.instance
      .collection('raffles')
      .doc(documentId);
  final productSnapshot = await productDocRef.get();
  final productData = productSnapshot.data();
  startDate = productData?['startDate']?.toDate() as DateTime?;
  endDate = productData?['endDate']?.toDate() as DateTime?;
  if (endDate != null) {
    // Schedule the callback for this product's endDate
    scheduleEndDateCallback(endDate!, documentId);
  }

  updateTimerStatus();
}
void updateTimerStatus() {
  if (startDate != null && endDate != null) {
    final now = DateTime.now();
    if (now.isBefore(startDate!)) {
      _startTimer();
    } else if (now.isAfter(endDate!)) {
      _stopTimer();
    }
  }
  buttonEnabledController
      .add(!_timerActive && !_adLoading && !isEndDateReached());
}

void _startTimer() {
  if (!_timerActive) {
    _timerActive = true;
    _loadingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(startDate!)) {
        _stopTimer();
        updateTimerStatus();
      }
    });
  }
}

void _stopTimer() {
  _timerActive = false;
  _loadingTimer?.cancel();
  _loadingTimer = null;
}