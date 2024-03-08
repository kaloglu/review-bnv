import 'dart:async';
import 'package:cihan_app/Presentation/providers/ad_reward_profile%20screen.dart';
import 'package:cihan_app/presentation/screens/edit_profile_screen.dart';
import 'package:cihan_app/presentation/screens/ticket_history_screen.dart';
import 'package:cihan_app/presentation/screens/winner_history_screen.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Data/services/auth_gate.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';
import '../providers/enroll_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/ticket_data.dart';

import '../utils/container_counter.dart';
import '../utils/lang.dart';
import 'enroll_history_screen.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});
  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();

    updateWinCount();
    // initDeepLinkData();
    // listenDynamicLinks();
    createRewardedInterstitialAd();

    //FlutterBranchSdk.setIdentity('branch_user_test');
  }

  @override
  void dispose() {
    rewardedInterstitialAd?.dispose();
    super.dispose();
  }

  int userWinCount = 0;
  Future<void> updateWinCount() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    int winCount = await countUserWins(userId!);
    setState(() {
      userWinCount = winCount;
    });
  }

  Future<int> countUserWins(String userId) async {
    final QuerySnapshot rafflesSnapshot = await FirebaseFirestore.instance
        .collectionGroup('winners')
        .where('userId', isEqualTo: userId)
        .get();

    return rafflesSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final profiledata = ref.watch(profileStreamProvider);
    final totalRemain = ref.watch(totalRemainProvider);
    final enrollData = ref.watch(enrollStreamProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          AppStrings.profile,
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, // Change your back button color here
        ),
        actions: [
          IconButton(
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                            users: FirebaseAuth.instance.currentUser,
                          )));
            },
            icon: const Icon(
              EvaIcons.edit2Outline,
            ),
          )
        ],
      ),
      body: profiledata.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noDataFound,
                style: kMediumTextStyle.copyWith(fontWeight: FontWeight.w700),
              ),
            );
          } else {
            final profileModel = data.first;
            return ListView(
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.5, 0.9],
                      colors: [
                        Color(0XFF9fd8ef),
                        Color(0XFFdbf0f9),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          CircleAvatar(
                            minRadius: 55,
                            backgroundColor: AppColors.primaryColor,
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(profileModel.profilepic),
                              minRadius: 50,
                            ),
                          ),
                        ],
                      ),
                      12.ph,
                      Text(
                        profileModel.fullname,
                        style: kLargeTextStyle,
                      ),
                      Text(
                        '${profileModel.city}, Turkiye',
                        style: kMediumTextStyle,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    CounterWithContainerIcon(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TicketHistory(),
                            ),
                          );
                        },
                        imagePath: 'assets/images/ticket1.png',
                        count: totalRemain.when(
                          data: (totalSum) {
                            return totalSum != null
                                ? Text(
                                    totalSum.toString(),
                                    style: kMediumTextStyle,
                                  )
                                : Center(
                                    child: Text(
                                      '0',
                                      style: kMediumTextStyle.copyWith(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                          },
                          error: (error, stackTrace) {
                            return Center(
                              child: Text(error.toString()),
                            );
                          },
                          loading: () {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        )),
                    CounterWithContainerIcon(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EnrollHistory(),
                          ),
                        );
                      },
                      imagePath: 'assets/images/person1.png',
                      count: enrollData.when(
                          data: (data) {
                            if (data.isEmpty) {
                              return Center(
                                child: Text(
                                  '0',
                                  style: kMediumTextStyle.copyWith(
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            }
                            final enrollList =
                                data; // Handle the case when data is null
                            final enrollCount = enrollList.length;
                            return Text(
                              enrollCount.toString(),
                              style: kMediumTextStyle,
                            );
                          },
                          error: (error, stackTrace) =>
                              Center(child: Text(error.toString())),
                          loading: () => const CircularProgressIndicator()),
                    ),
                    CounterWithContainerIcon(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WinnerHistoryPage(),
                          ),
                        );
                      },
                      imagePath: 'assets/images/trophy1.png',
                      count: Text(
                        userWinCount.toString(),
                        style: kMediumTextStyle,
                      ),
                    )
                  ],
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    AppStrings.email,
                    style: kSmallTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(profileModel.email),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    AppStrings.phone,
                    style: kSmallTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(profileModel.phone),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    AppStrings.address,
                    style: kSmallTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle:
                      Text('${profileModel.address}, ${profileModel.city}'),
                ),
                const Divider(),
                10.ph,
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .primarySecondaryBackground, // Change the background color
                          // If AppColors does not have yourCustomColor, replace it with a Color widget, e.g., Colors.blue
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                        appBar: AppBar(
                                          title: Text(
                                            AppStrings.accountManagement,
                                            style: kMediumTextStyle.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          centerTitle: true,
                                          backgroundColor:
                                              AppColors.primaryColor,
                                        ),
                                        actions: [
                                          SignedOutAction((context) {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AuthGate()),
                                              (route) => false,
                                            );
                                            Fluttertoast.showToast(
                                              msg: AppStrings
                                                  .youAreSuccessfullyLogOut,
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16,
                                            );
                                          }),
                                          AuthStateChangeAction<
                                                  CredentialLinked>(
                                              (context, state) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(AppStrings
                                                    .accountSuccessfullyLinked),
                                              ),
                                            );
                                          }),
                                        ],
                                      )));
                        },
                        child: Text(
                          AppStrings.linkOtherSocialMediaAccounts,
                          style: kSmallTextStyle.copyWith(
                              fontWeight: FontWeight.w700),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            //height: 35,
                            margin: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  textStyle: MaterialStatePropertyAll(
                                      kSmallTextStyle.copyWith(fontSize: 15)),
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          Color(0XFF87ceeb))),
                              onPressed: () {
                                showRewardedInterstitialAd();
                              },
                              child:
                                  // const SizedBox(
                                  //    width: 20, // Adjust this value as needed
                                  //    height: 20, // Adjust this value as needed
                                  //    child: CircularProgressIndicator(
                                  //      strokeWidth:
                                  //          2, // You can adjust the stroke width as needed
                                  //    ),
                                  //  )
                                  Text(
                                AppStrings.watchEarn,
                                style: kSmallTextStyle.copyWith(
                                    fontWeight: FontWeight.w900, fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                        //  const SizedBox(width: 10),
                        // Expanded(
                        //   child: Container(
                        //     width: MediaQuery.of(context).size.width,
                        //     // height: 35,
                        //     margin: const EdgeInsets.all(9),
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(24),
                        //     ),
                        //     child: ElevatedButton(
                        //       style: ButtonStyle(
                        //           textStyle: MaterialStatePropertyAll(
                        //               kSmallTextStyle.copyWith(fontSize: 16)),
                        //           backgroundColor:
                        //               const MaterialStatePropertyAll(
                        //                   Color(0XFF87ceeb))),
                        //       onPressed: () {
                        //         generateLink(context);
                        //       },
                        //
                        //       // ReferAndEarnScreen();
                        //       //},
                        //
                        //       child: Text(
                        //         AppStrings.inviteEarn,
                        //         style: kSmallTextStyle.copyWith(
                        //             fontWeight: FontWeight.w700),
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ],
                )
              ],
            );
          }
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
