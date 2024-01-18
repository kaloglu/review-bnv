import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Data/services/connectivity.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../utils/Text.dart';


class WinnerData {
  final String userId;
  final String raffleId;

  WinnerData({required this.userId, required this.raffleId});
}

class RaffleInfo {
  final String title;
  final String image;

  RaffleInfo({required this.title, required this.image});
}

class WinnerHistoryPage extends StatefulWidget {
  const WinnerHistoryPage({super.key});

  //final String userId;

  // WinnerHistoryPage({required this.userId});

  @override
  WinnerHistoryPageState createState() => WinnerHistoryPageState();
}

class WinnerHistoryPageState extends State<WinnerHistoryPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final connectivity = ConnectivityService();
    connectivity.connectivityStream.listen((isConnected) {
      if (!isConnected) {
        const CircularProgressIndicator();
        // Show ShimmerLoader for a few seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (!isConnected) {

            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: const Text(
                    'No internet connection. Please check your network settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {

                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ));
          }
        });
      }});
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //late final String userId;

  //WinnerHistoryPageState({this.userId});

  Future<List<Map<String, dynamic>>?> fetchWinners() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      final QuerySnapshot winnersSnapshot = await firestore
          .collectionGroup('winners')
          .where('userId', isEqualTo: userId)
          .get();

      return winnersSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } else {
      // Handle the case where the user is not authenticated
      return null;
    }
  }

  Future<RaffleInfo?> fetchRaffleInfo(String raffleId) async {
    final DocumentSnapshot raffleSnapshot =
        await firestore.collection('raffles').doc(raffleId).get();
    if (raffleSnapshot.exists) {
      final raffleData = raffleSnapshot.data() as Map<String, dynamic>;
      return RaffleInfo(
        title: raffleData['title'] as String,
        image: raffleData['image'] as String,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          AppStrings.winnerHistory,
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: fetchWinners(),
        builder: (context, winnersSnapshot) {
          if (winnersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (winnersSnapshot.hasError) {
            return Text('Error: ${winnersSnapshot.error}');
          }
          if (!winnersSnapshot.hasData || winnersSnapshot.data!.isEmpty) {
            return  Padding(
              padding: const EdgeInsets.all(35.0),
              child: Center
                (
                  child:
                  Text(AppStrings.youHaveNotWonAnyRaffleYet,style: kMediumTextStyle,)),
            );
          }

          return ListView.builder(
            itemCount: winnersSnapshot.data!.length,
            itemBuilder: (context, index) {
              final winnerData = WinnerData(
                userId: winnersSnapshot.data![index]['userId'] as String,
                raffleId: winnersSnapshot.data![index]['raffleId'] as String,
              );

              return FutureBuilder<RaffleInfo?>(
                future: fetchRaffleInfo(winnerData.raffleId),
                builder: (context, raffleInfoSnapshot) {
                  if (raffleInfoSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Text('');
                  }
                  if (raffleInfoSnapshot.hasError) {
                    return Text('Error: ${raffleInfoSnapshot.error}');
                  }

                  final raffleInfo = raffleInfoSnapshot.data;
                  if (raffleInfo == null) {
                    return const Text(AppStrings.noRaffleFound);
                  }

                  return Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Image.network(raffleInfo.image),
                        Text(
                          raffleInfo.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          AppStrings.congratulationYouWon,
                          style: kMediumTextStyle.copyWith(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
