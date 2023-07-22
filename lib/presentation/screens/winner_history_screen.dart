import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';

class WinnerHistory extends StatelessWidget {
  const WinnerHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Winner History',
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: winnerHistory.length,
        itemBuilder: (context, index) {
          Map allWinnerData = winnerHistory[index];
          return ListTile(
            title: Text(
              allWinnerData['title'],
              style: kMediumTextStyle,
            ),
            trailing: Text(
              allWinnerData['ticket_number'],
              style: kSmallTextStyle,
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider();
        },
      ),
    );
  }
}

List<Map> winnerHistory = [
  {
    'title': 'Watch ad',
    'ticket_number': '6',
  },
  {
    'title': 'Invite friend',
    'ticket_number': '10',
  },
  {
    'title': 'Watch Video',
    'ticket_number': '8',
  },
  {
    'title': 'Share online',
    'ticket_number': '12',
  },
  {
    'title': 'Watch ad',
    'ticket_number': '6',
  },
  {
    'title': 'Invite friend',
    'ticket_number': '10',
  },
  {
    'title': 'Watch Video',
    'ticket_number': '8',
  },
  {
    'title': 'Share online',
    'ticket_number': '12',
  },
  {
    'title': 'Watch ad',
    'ticket_number': '6',
  },
  {
    'title': 'Invite friend',
    'ticket_number': '10',
  },
  {
    'title': 'Watch Video',
    'ticket_number': '8',
  },
  {
    'title': 'Share online',
    'ticket_number': '12',
  },
];
