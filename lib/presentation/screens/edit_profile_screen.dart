import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cihan_app/presentation/utils/spacing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../constants/app_colors.dart';
import '../../constants/text_styles.dart';
import '../utils/icon_buttons.dart';
import '../utils/profile_edit_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firestore = FirebaseFirestore.instance.collection('users');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  bool showSpinner = false;
  bool hasCompletedProfile = false;

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  // Add this function to get the device token and update the user's document
  Future<void> updateDeviceToken() async {
    try {
      String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken != null) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String uid = user.uid;
          // Update the 'deviceToken' field in the user's document in Firestore
          final userRef =
              FirebaseFirestore.instance.collection('users').doc(uid);

          // Check if the document already exists
          final userSnapshot = await userRef.get();
          if (userSnapshot.exists) {
            // If the document exists, update the deviceToken using update() method
            await userRef.update({'deviceToken': deviceToken});
          } else {
            // If the document doesn't exist, create a new document using set() method
            await userRef
                .set({'deviceToken': deviceToken}, SetOptions(merge: true));
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating device token: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Call the updateDeviceToken method when the screen is loaded
    updateDeviceToken();
    checkProfileCompletion(); // Call this method to check profile completion status
  }

  // Method to check if the user has completed their profile or not
// Method to check if the user has completed their profile or not
  void checkProfileCompletion() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      userRef.get().then((userSnapshot) {
        if (userSnapshot.exists) {
          // If the document exists, check if all fields are filled
          final data = userSnapshot.data();
          bool allFieldsFilled = data?['fullname'] != null &&
              data?['email'] != null &&
              data?['phone'] != null &&
              data?['address'] != null &&
              data?['city'] != null &&
              data?['country'] != null;

          // Set the profile completion status based on whether all fields are filled
          setState(() {
            hasCompletedProfile = allFieldsFilled;
          });
        }
      });
    }
  }

  uploadImage(File image) async {
    String imageurl = '';
    // String fileName  = Path.combine(, path1, path2);
    var reference = FirebaseStorage.instance.ref().child('user/');
    UploadTask uploadTask = reference.putFile(image);

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageurl = value;
    });
    return imageurl;
  }

// Method to set the profile completion status after the first successful completion
  void setProfileCompletionStatus(bool isCompleted) {
    setState(() {
      hasCompletedProfile = isCompleted;
    });
  }

  void updateProfile() async {
    try {
      // If the user has not completed their profile, show a toast message
      if (!hasCompletedProfile) {
        // Check if any of the fields are empty
        if (nameController.text.isEmpty ||
            emailController.text.isEmpty ||
            phoneController.text.isEmpty ||
            addressController.text.isEmpty ||
            cityController.text.isEmpty ||
            countryController.text.isEmpty) {
          Fluttertoast.showToast(
            msg: "Please fill all the fields",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
          return; // Return early to prevent further processing
        }

        // Check if the image is not selected
        if (selectedImage == null) {
          Fluttertoast.showToast(
            msg: "Please upload a profile picture",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16,
          );
          return; // Return early to prevent further processing
        }
      }

      setState(() {
        showSpinner = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        String? imageUrl;
        if (selectedImage != null) {
          imageUrl = await uploadImage(selectedImage!);
        }

        // Continue with the update process
        final dataToSave = <String, dynamic>{};

        if (uid.isNotEmpty) {
          dataToSave['uid'] = uid;
        }
        if (imageUrl != null) {
          dataToSave['profilepic'] = imageUrl;
        }
        if (nameController.text.isNotEmpty) {
          dataToSave['fullname'] = nameController.text;
        }
        if (emailController.text.isNotEmpty) {
          dataToSave['email'] = emailController.text;
        }
        if (phoneController.text.isNotEmpty) {
          dataToSave['phone'] = phoneController.text;
        }
        if (addressController.text.isNotEmpty) {
          dataToSave['address'] = addressController.text;
        }
        if (countryController.text.isNotEmpty) {
          dataToSave['country'] = countryController.text;
        }
        if (cityController.text.isNotEmpty) {
          dataToSave['city'] = cityController.text;
        }

        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

        // Check if the document already exists
        final userSnapshot = await userRef.get();
        if (userSnapshot.exists) {
          // If the document exists, update the fields using update() method
          await userRef.update(dataToSave);
          // Set the profile completion status to true after the first successful completion
          setProfileCompletionStatus(true);
        } else {
          // If the document doesn't exist, create a new document using set() method
          await userRef.set(dataToSave);
          // Set the profile completion status to true after the first successful completion
          setProfileCompletionStatus(true);
        }

        nameController.clear();
        emailController.clear();
        phoneController.clear();
        addressController.clear();
        cityController.clear();
        countryController.clear();


        setState(() {
          showSpinner = false;
        });

        Fluttertoast.showToast(
          msg: "Update Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    } catch (e) {
      setState(() {
        showSpinner = false;
      });

      Fluttertoast.showToast(
        msg: "Update Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );

      debugPrint('Error updating user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            centerTitle: true,
            title: Text(
              'Edit Profile',
              style: kMediumTextStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView(
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
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: InkWell(
                        onTap: () {
                          getImage(ImageSource.gallery);
                        },
                        child: selectedImage == null
                            ? Container(
                                width: 110,
                                height: 120,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      EvaIcons.edit2Outline,
                                      size: 30,
                                    )),
                              )
                            : Container(
                                width: 110,
                                height: 120,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(selectedImage!),
                                        fit: BoxFit.fill),
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                    12.ph,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ProfileTextFields(
                      controller: nameController,
                      hintText: 'XYZ ABC',
                      labelText: 'Name',
                    ),
                    ProfileTextFields(
                      controller: emailController,
                      hintText: 'asdf@gmail.com',
                      labelText: 'Email',
                    ),
                    ProfileTextFields(
                      controller: phoneController,
                      hintText: '+64231313456',
                      labelText: 'Phone',
                    ),
                    ProfileTextFields(
                      controller: countryController,
                      hintText: 'Turkiye',
                      labelText: 'Country',
                    ),
                    TypeAheadFormField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          labelStyle: kSmallTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Select your city',
                        ),
                      ),
                      suggestionsCallback: (pattern) {
                        return turkeyCities
                            .where((city) => city
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      onSuggestionSelected: (String? suggestion) {
                        if (suggestion != null) {
                          cityController.text = suggestion;
                        }
                      },
                    ),
                    ProfileTextFields(
                      controller: addressController,
                      hintText: "Istanbul",
                      labelText: 'Address',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 150,
                  height: 35,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        backgroundColor: const Color.fromRGBO(10, 91, 144, 1),
                      ),
                      onPressed: () {
                        updateProfile();
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                ),
              ),
              10.ph,
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     MyIconButtons(
              //       icon: EvaIcons.google,
              //     ),
              //     MyIconButtons(
              //       icon: EvaIcons.twitter,
              //     ),
              //     MyIconButtons(
              //       icon: EvaIcons.facebook,
              //     ),
              //     MyIconButtons(
              //       icon: EvaIcons.phone,
              //     ),
              //     MyIconButtons(
              //       icon: EvaIcons.logOut,
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:cihan_app/presentation/utils/spacing.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import '../../constants/app_colors.dart';
// import '../../constants/text_styles.dart';
// import '../utils/icon_buttons.dart';
// import '../utils/profile_edit_textfield.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final firestore = FirebaseFirestore.instance.collection('users');
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController cityController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController countryController = TextEditingController();
//   bool showSpinner = false;
//
//   // Add this function to get the device token and update the user's document
//   Future<void> updateDeviceToken() async {
//     try {
//       String? deviceToken = await FirebaseMessaging.instance.getToken();
//       if (deviceToken != null) {
//         User? user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           String uid = user.uid;
//           // Update the 'deviceToken' field in the user's document in Firestore
//           final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
//
//           // Check if the document already exists
//           final userSnapshot = await userRef.get();
//           if (userSnapshot.exists) {
//             // If the document exists, update the deviceToken using update() method
//             await userRef.update({'deviceToken': deviceToken});
//           } else {
//             // If the document doesn't exist, create a new document using set() method
//             await userRef.set({'deviceToken': deviceToken}, SetOptions(merge: true));
//           }
//         }
//       }
//     } catch (e) {
//       print('Error updating device token: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     // Call the updateDeviceToken method when the screen is loaded
//     updateDeviceToken();
//   }
//
//   final ImagePicker _picker = ImagePicker();
//   File? selectedImage;
//   getImage(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     if (image != null) {
//       selectedImage = File(image.path);
//       setState(() {});
//     }
//   }
//
//   uploadImage(File image) async {
//     String imageurl = '';
//     // String fileName  = Path.combine(, path1, path2);
//     var reference = FirebaseStorage.instance.ref().child('user/');
//     UploadTask uploadTask = reference.putFile(image);
//
//     TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
//     await taskSnapshot.ref.getDownloadURL().then((value) {
//       imageurl = value;
//     });
//     return imageurl;
//   }
//
//   void updateProfile() async {
//     try {
//       setState(() {
//         showSpinner = true;
//       });
//
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final uid = user.uid;
//         String? imageUrl;
//         if (selectedImage != null) {
//           imageUrl = await uploadImage(selectedImage!);
//         }
//
//         // Check if both city and address fields are empty
//         bool areCityAndAddressEmpty = cityController.text.isEmpty && addressController.text.isEmpty;
//         if (areCityAndAddressEmpty && nameController.text.isEmpty &&
//             emailController.text.isEmpty && phoneController.text.isEmpty &&
//             countryController.text.isEmpty) {
//           setState(() {
//             showSpinner = false;
//           });
//
//           Fluttertoast.showToast(
//             msg: "Please enter some information",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.CENTER,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.black,
//             textColor: Colors.white,
//             fontSize: 16,
//           );
//           return; // Return early to prevent further processing
//         }
//
//         // Check if both city and address fields are not empty
//         if (!areCityAndAddressEmpty && (cityController.text.isEmpty || addressController.text.isEmpty)) {
//           setState(() {
//             showSpinner = false;
//           });
//
//           Fluttertoast.showToast(
//             msg: "Please enter both city and address",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.CENTER,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.black,
//             textColor: Colors.white,
//             fontSize: 16,
//           );
//           return; // Return early to prevent further processing
//         }
//
//         // Continue with the update process
//         final dataToSave = <String, dynamic>{};
//
//         if (uid.isNotEmpty) {
//           dataToSave['uid'] = uid;
//         }
//         if (imageUrl != null) {
//           dataToSave['profilepic'] = imageUrl;
//         }
//         if (nameController.text.isNotEmpty) {
//           dataToSave['fullname'] = nameController.text;
//         }
//         if (emailController.text.isNotEmpty) {
//           dataToSave['email'] = emailController.text;
//         }
//         if (phoneController.text.isNotEmpty) {
//           dataToSave['phone'] = phoneController.text;
//         }
//         if (addressController.text.isNotEmpty) {
//           dataToSave['address'] = addressController.text;
//         }
//         if (countryController.text.isNotEmpty) {
//           dataToSave['country'] = countryController.text;
//         }
//         if (cityController.text.isNotEmpty) {
//           dataToSave['city'] = cityController.text;
//         }
//
//         final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
//
//         // Check if the document already exists
//         final userSnapshot = await userRef.get();
//         if (userSnapshot.exists) {
//           // If the document exists, update the fields using update() method
//           await userRef.update(dataToSave);
//         } else {
//           // If the document doesn't exist, create a new document using set() method
//           await userRef.set(dataToSave);
//         }
//
//
//
//
//
//
//
//
//        // await FirebaseFirestore.instance.collection('users').doc(uid).set(dataToSave);//error in update and device token
//
//         nameController.clear();
//         emailController.clear();
//         phoneController.clear();
//         addressController.clear();
//         cityController.clear();
//         countryController.clear();
//
//         setState(() {
//           showSpinner = false;
//         });
//
//         Fluttertoast.showToast(
//           msg: "Update Successful",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.CENTER,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.black,
//           textColor: Colors.white,
//           fontSize: 16,
//         );
//       }
//     } catch (e) {
//       setState(() {
//         showSpinner = false;
//       });
//
//       Fluttertoast.showToast(
//         msg: "Update Failed",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.CENTER,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.black,
//         textColor: Colors.white,
//         fontSize: 16,
//       );
//
//       print('Error updating user profile: $e');
//     }
//   }
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return ModalProgressHUD(
//       inAsyncCall: showSpinner,
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.grey.shade100,
//           appBar: AppBar(
//             backgroundColor: AppColors.primaryColor,
//             centerTitle: true,
//             title: Text(
//               'Edit Profile',
//               style: kMediumTextStyle.copyWith(
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           body: ListView(
//             children: <Widget>[
//               Container(
//                 height: 200,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.centerLeft,
//                     end: Alignment.centerRight,
//                     stops: [0.5, 0.9],
//                     colors: [
//                       Color(0XFF9fd8ef),
//                       Color(0XFFdbf0f9),
//                     ],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: InkWell(
//                         onTap: () {
//                           getImage(ImageSource.gallery);
//                         },
//                         child: selectedImage == null
//                             ? Container(
//                                 width: 110,
//                                 height: 120,
//                                 margin: const EdgeInsets.only(bottom: 20),
//                                 decoration: const BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.white),
//                                 child: const Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: Icon(
//                                       EvaIcons.edit2Outline,
//                                       size: 30,
//                                     )),
//                               )
//                             : Container(
//                                 width: 110,
//                                 height: 120,
//                                 margin: const EdgeInsets.only(bottom: 20),
//                                 decoration: BoxDecoration(
//                                     image: DecorationImage(
//                                         image: FileImage(selectedImage!),
//                                         fit: BoxFit.fill),
//                                     shape: BoxShape.circle,
//                                     color: Colors.white),
//                               ),
//                       ),
//                     ),
//
//                     12.ph,
//
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     ProfileTextFields(
//                       controller: nameController,
//                       hintText: 'XYZ ABC',
//                       labelText: 'Name',
//                     ),
//                     ProfileTextFields(
//                       controller: emailController,
//                       hintText: 'asdf@gmail.com',
//                       labelText: 'Email',
//                     ),
//                     ProfileTextFields(
//                       controller: phoneController,
//                       hintText: '+64231313456',
//                       labelText: 'Phone',
//                     ),
//                     ProfileTextFields(
//                       controller: countryController,
//                       hintText: 'Turkiye',
//                       labelText: 'Country',
//                     ),
//                     TypeAheadFormField<String>(
//                       textFieldConfiguration: TextFieldConfiguration(
//                         controller: cityController,
//                         decoration: InputDecoration(
//                           labelText: 'City',
//                           labelStyle: kSmallTextStyle.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                           hintText: 'Select your city',
//                         ),
//                       ),
//                       suggestionsCallback: (pattern) {
//                         return turkeyCities
//                             .where((city) => city
//                                 .toLowerCase()
//                                 .contains(pattern.toLowerCase()))
//                             .toList();
//                       },
//                       itemBuilder: (context, suggestion) {
//                         return ListTile(
//                           title: Text(suggestion),
//                         );
//                       },
//                       onSuggestionSelected: (String? suggestion) {
//                         if (suggestion != null) {
//                           cityController.text = suggestion;
//                         }
//                       },
//                     ),
//                     ProfileTextFields(
//                       controller: addressController,
//                       hintText: "Istanbul",
//                       labelText: 'Address',
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: SizedBox(
//                   width: 150,
//                   height: 35,
//                   child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(13.0),
//                         ),
//                         backgroundColor: const Color.fromRGBO(10, 91, 144, 1),
//                       ),
//                       onPressed: () {
//
//
//                         updateProfile();
//
//                       },
//                       child: const Text(
//                         'Update',
//                         style: TextStyle(fontSize: 20, color: Colors.white),
//                       )),
//                 ),
//               ),
//               10.ph,
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   MyIconButtons(
//                     icon: EvaIcons.google,
//                   ),
//                   MyIconButtons(
//                     icon: EvaIcons.twitter,
//                   ),
//                   MyIconButtons(
//                     icon: EvaIcons.facebook,
//                   ),
//                   MyIconButtons(
//                     icon: EvaIcons.phone,
//                   ),
//                   MyIconButtons(
//                     icon: EvaIcons.logOut,
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
final List<String> turkeyCities = [
  'Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Adana', 'Antalya', 'Konya',
  'Gaziantep',
  'Mersin', 'Diyarbakir', 'Kayseri', 'Eskisehir', 'Hatay', 'Samsun',
  'Denizli', 'Sanliurfa',
  'Adapazari', 'Malatya', 'Kahramanmaras', 'Van', 'Elazig',
  'Manisa', 'Sivas', 'Gebze',
  'Balikesir', 'Tarsus', 'Kocaeli', 'Erzurum',

  'Iskenderun', 'Osmaniye', 'Corlu', 'Kutahya', 'Eskisehir',
  'Nazilli', 'Antakya', 'Gaziantep', 'Sisli',
  'Muratpasa', 'Aydin', 'Usak', 'Karabuk', 'Karaman', 'Nigde', 'Ordu',
  'Erzincan', 'Sivas', 'Erzurum', 'Atasehir',
  'Esenyurt', 'Silivri', 'Gebze', 'Sultangazi',
  'Basaksehir', 'Elazig',
  'Yozgat', 'Bagcilar',
  'Gungoren', 'Sultanbeyli', 'Aksaray', 'Inegol',
  'Tokat', 'Denizli', 'Malatya', 'Cankaya', 'Umraniye', 'Batman', 'Baglar',
  'Esenyurt', 'Bahcelievler', 'Van', 'Bakirkoy', 'Siirt', 'Kusadasi',
  'Orhangazi', 'Karakoy',
  'Buyukcekmece', '   ', 'Samandira', 'Mardin', 'Ceyhan',
  'Sarigerme', 'Isparta', 'Bolu', 'Afyonkarahisar', 'Rize', 'Zonguldak',
  'Duzce',
  'Torbali', 'Corum', 'Nazilli', 'Gerede', 'Edirne',
  'Giresun', 'Karsiyaka',
  'Ayvalik', 'Milas', 'Iskenderun', 'Didim', 'Marmaris', 'Mudanya', 'Urla',
  'Denizli', 'Burhaniye',
  'Beylikduzu', 'Tire', 'Kirklareli', 'Seferihisar', 'Yenisehir',
  'Belek', 'Dalaman', 'Gocek', 'Kemer',
  'Kemer', 'Side', 'Demre', 'Ortaca', 'Kusadasi', 'Kumluca', 'Ayvacik',
  'Ayvacik', 'Golturkbuku', 'Cesme',
  'Avsallar', 'Kayakoy', 'Pamukkale',
  'Belek', 'Golturkbuku',
  'Golturkbuku', 'Kayakoy', 'Kemer', 'Foca', 'Golturkbuku',
  'Hisaronu', 'Kas', 'Pamukkale',
  'Koycegiz', 'Selimiye', 'Icmeler', 'Koycegiz', 'Selimiye', 'Guzelcamli',
  'Gocek', 'Torba', 'Altinkum', 'Ovacik', 'Hisaronu',
  'Bogazkent', 'Datca', 'Bogazkent', 'Kumkoy', 'Bitez', 'Ortakent',
  'Kalkan',
  'Marmaris', 'Sogut', 'Mesudiye', 'Gumbet', 'Oren', 'Turunc',
  'Bozburun', 'Bodrum', 'Oludeniz', 'Ovacik', 'Ciftlik',
  'Sogut', 'Gumusluk', 'Turgutreis', 'Gokova',
  'Akyaka',
  'Ciftlik', ' Fethiye', 'Oludeniz', 'Mazi',
  'Kayakoy',
  'Gokbel',
  'Yaniklar',
  'Gulluk',
  'Uzumlu',

  'Camyuva',
  'Kucukkuyu',

  'Karacabey',
  'Mustafakemalpasa',

  'Bitez',
  'Uzumlu',
  'Yaniklar',
  'Bozcaada',
  'Gumusluk',
  'Gokceovacik',

  'Gokbel',
  'Patara'
      'Faraly'

  // Add more cities here
];
