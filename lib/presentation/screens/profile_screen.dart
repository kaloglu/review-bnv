import 'package:cihan_app/presentation/screens/edit_profile_screen.dart';
import 'package:cihan_app/presentation/screens/ticket_history_screen.dart';
import 'package:cihan_app/presentation/screens/winner_history_screen.dart';
import 'package:cihan_app/presentation/utils/icon_buttons.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:cihan_app/providers/profile_provider.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../utils/container_counter.dart';
import '../utils/count_with_icon.dart';
import 'enroll_history_screen.dart';

class UserProfileScreen extends ConsumerWidget {
   UserProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiledata = ref.watch(profileStreamProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        title: Text(
          'Profile',
          style: kMediumTextStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       FirebaseAuth.instance.signOut();
          //       // SignedOutAction((context) {
          //       //   Navigator.of(context).pushReplacement(
          //       //     MaterialPageRoute(
          //       //       builder: (context) => const SignInScreen(),
          //       //     ),
          //       //   );
          //       // });
          //     },
          //     color: Colors.black,
          //     icon: const Icon(Icons.account_box_sharp)),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()));
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
        return const Center(
          child: Text('Please Complete Your Profile'),
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
                            backgroundImage: NetworkImage(profileModel.profilepic),
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
                    Text('${profileModel.city}, ${profileModel.country}',style: kMediumTextStyle,
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
                    count: '12',
                  ),
                  CounterWithContainerIcon(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EnrollHistory(),
                        ),
                      );
                    },
                    imagePath: 'assets/images/person1.png',
                    count: '18',
                  ),
                  CounterWithContainerIcon(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WinnerHistory(),
                        ),
                      );
                    },
                    imagePath: 'assets/images/trophy1.png',
                    count: '18',
                  ),
                ],
              ),

              const Divider(),
              ListTile(
                title: Text(
                  "Email",
                  style: kSmallTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(profileModel.email
                ?? 'N/A'),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  "Phone",
                  style: kSmallTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(profileModel.phone ?? 'N/A'),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  "Address",
                  style: kSmallTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('${profileModel.address}, ${profileModel.city}'),
              ),
              const Divider(),
              10.ph,
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                ElevatedButton(
                    onPressed:(){
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(
                       appBar: AppBar(
                         title: Text('Account Management',style: kMediumTextStyle.copyWith(
                           fontWeight: FontWeight.w700,
                         ),),
                         centerTitle: true,
                         backgroundColor: AppColors.primaryColor,
                       ),
                       avatar: Center(child: Text('Manage Your Accounts',style: kMediumTextStyle.copyWith(fontWeight: FontWeight.w700),)),
                       // actions: [
                       //   SignedOutAction((context) {
                       //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignInScreen()),result: false);
                       //   })
                       // ],


                       
                     )));
                    }, child: Text('Link Other Social Media Accounts',style: kSmallTextStyle.copyWith(fontWeight: FontWeight.w700),)),
                  // const MyIconButtons(
                  //   icon: EvaIcons.twitter,
                  // ),
                  // const MyIconButtons(
                  //   icon: EvaIcons.facebook,
                  // ),
                  // const MyIconButtons(
                  //   icon: EvaIcons.phone,
                  // ),
                  // const MyIconButtons(
                  //   icon: EvaIcons.logOut,
                  // ),
                ],
              )
            ],
          );
        }},
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
