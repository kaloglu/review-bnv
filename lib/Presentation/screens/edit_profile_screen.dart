import 'dart:io';

import 'package:cihan_app/presentation/screens/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/lang.dart';
import '../constants/app_colors.dart';
import '../constants/text_styles.dart';

import '../utils/profile_edit_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key, this.users}) : super(key: key);

  final User? users;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isTwitterOrPhoneLogin = false;
  String? emailValue;
  final firestore = FirebaseFirestore.instance.collection('users');

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  // final TextEditingController countryController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool showSpinner = false;
  bool hasCompletedProfile = false;

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isPhoneLogin() {
    final users = widget.users;
    return users?.providerData[0].providerId == 'phone';
  }

  @override
  Widget build(BuildContext context) {
    final bool phoneLogin = !isPhoneLogin();
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          title: Text(
            AppStrings.editProfile,
            style: kMediumTextStyle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black, // Change your back button color here
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
                        // getImage(ImageSource.gallery);
                      },
                      child: _buildProfilePhoto(),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ProfileTextFields(
                    readonly: phoneLogin,
                    controller: nameController,
                    hintText: 'Please Enter Your Name',
                    labelText: AppStrings.name,
                  ),
                  ProfileTextFields(
                    readonly: isTwitterOrPhoneLogin ? false : true,
                    controller: emailController,
                    hintText: 'Please Enter Your Email',
                    labelText: AppStrings.email,
                  ),
                  ProfileTextFields(
                    readonly: !phoneLogin, // Invert for phone login
                    controller: phoneController,
                    hintText: 'Please Enter Your Number',
                    labelText: AppStrings.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  TypeAheadFormField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: AppStrings.city,
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
                    readonly: false,
                    controller: addressController,
                    hintText: 'Please Enter Your Address',
                    labelText: AppStrings.address,
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
                    _markProfileCompleted();
                  },
                  child: const Text(
                    AppStrings.update,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    final users = widget.users;
    if (users != null && users.photoURL != null) {
      return GestureDetector(
        onTap: () {
          // Logic to open gallery when the user taps on the profile photo
          if (users.photoURL == null && selectedImage == null) {
            getImage(ImageSource.gallery);
          }
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(users.photoURL!),
          radius: 50,
        ),
      );
    } else if (selectedImage != null) {
      return GestureDetector(
        onTap: () {
          // Logic to open gallery when the user taps on the profile photo
          if (users?.photoURL == null && selectedImage == null) {
            getImage(ImageSource.gallery);
          }
        },
        child: CircleAvatar(
          backgroundImage: FileImage(selectedImage!),
          radius: 50,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          // Logic to open gallery when the user taps on the profile photo
          if (users?.photoURL == null && selectedImage == null) {
            getImage(ImageSource.gallery);
          }
        },
        child: const CircleAvatar(
          backgroundColor: Colors.grey, // Replace with default photo color
          radius: 50,
        ),
      );
    }
  }

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
    getProfileDataFromGoogleAccount();
    fetchProfileData();
  }

  void fetchProfileData() async {
    try {
      final user = widget.users;
      if (user != null) {
        final uid = user.uid;
        final userSnapshot = await firestore.doc(uid).get();

        if (userSnapshot.exists) {
          final data = userSnapshot.data();
          if (data != null) {
            setState(() {
              nameController.text = data['fullname'] ?? '';
              emailController.text = data['email'] ?? '';
              phoneController.text = data['phone'] ?? '';
              addressController.text = data['address'] ?? '';
              cityController.text = data['city'] ?? '';
              // countryController.text = data['country'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
    }
  }

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
              data?['city'] != null;
          // data?['country'] != null;

          if (allFieldsFilled) {
            // If all fields are filled, set the profile completion status to true
            setProfileCompletionStatus(true);

            // Populate the name and email fields from Firestore data
          } else {
            // If any field is not filled, set the profile completion status to false
            setProfileCompletionStatus(false);
          }
        }
      });
    }
  }

  void setProfileCompletionStatus(bool isCompleted) {
    setState(() {
      hasCompletedProfile = isCompleted;
    });
  }

  // uploadImage(File image) async {
  //   String imageurl = '';
  //   // String fileName  = Path.combine(, path1, path2);
  //   var reference = FirebaseStorage.instance.ref().child('user/');
  //   UploadTask uploadTask = reference.putFile(image);
  //
  //   TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  //   await taskSnapshot.ref.getDownloadURL().then((value) {
  //     imageurl = value;
  //   });
  //   return imageurl;
  // }

  void updateProfile() async {
    try {
      setState(() {
        showSpinner = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

         String? imageUrl;
        // if (selectedImage != null) {
        //   imageUrl = await uploadImage(selectedImage!);
        // } else {
        //   // If selectedImage is null, use the photo URL from the Google account directly
        //   final users = widget.users;
        //   if (users != null && users.photoURL != null) {
        //     imageUrl = users.photoURL;
        //   }
        // }

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

        // Check if the user is updating city or address
        bool isCityUpdated = cityController.text.isNotEmpty;
        bool isAddressUpdated = addressController.text.isNotEmpty;

        // If the user is updating either city or address
        if (isCityUpdated || isAddressUpdated) {
          // Check if both city and address are entered
          if (cityController.text.isEmpty || addressController.text.isEmpty) {
            Fluttertoast.showToast(
              msg: "Please enter both city and address",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            setState(() {
              showSpinner = false;
            });
            return; // Return early if any field is not entered
          }
        } else {
          // If the user is not updating city or address, make them mandatory to fill
          if (cityController.text.isEmpty || addressController.text.isEmpty) {
            Fluttertoast.showToast(
              msg: "Please fill all the fields",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16,
            );
            setState(() {
              showSpinner = false;
            });
            return; // Return early if any field is not entered
          }
        }

        if (addressController.text.isNotEmpty) {
          dataToSave['address'] = addressController.text;
        }

        if (cityController.text.isNotEmpty) {
          dataToSave['city'] = cityController.text;
        }

        // if (countryController.text.isNotEmpty) {
        //   dataToSave['country'] = countryController.text;
        // }

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

        // Clear the text fields and the selected image
        // nameController.clear();
        // emailController.clear();
        // phoneController.clear();
        // addressController.clear();
        // cityController.clear();
        // countryController.clear();
        // selectedImage = null; // Clear the selected image

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
        if (!mounted) {
          return;
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
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

  void getProfileDataFromGoogleAccount() {
    final users = widget.users;
    if (users != null && users.displayName != null) {
      nameController.text = users.displayName!;
    }

    if (users != null && users.email != null) {
      emailController.text = users.email!;
    }

    if (users != null && users.phoneNumber != null) {
      phoneController.text = users.phoneNumber!;
    }
    if (users != null && users.phoneNumber != null) {
      phoneController.text = users.phoneNumber!;
      setState(() {
        isTwitterOrPhoneLogin = true;
      });
    }

    if (users != null && users.providerData[0].providerId == 'twitter.com') {
      setState(() {
        isTwitterOrPhoneLogin = true;
      });
    }
  }

  void _markProfileCompleted() async {
    setState(() {});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('profileCompleted', true);
  }
}

final List<String> turkeyCities = [
  'Istanbul',
  'Ankara',
  'Izmir',
  'Bursa',
  'Adana',
  'Antalya',
  'Konya',
  'Gaziantep',
  'Mersin',
  'Diyarbakir',
  'Kayseri',
  'Eskisehir',
  'Hatay',
  'Samsun',
  'Denizli',
  'Sanliurfa',
  'Adapazari',
  'Malatya',
  'Kahramanmaras',
  'Van',
  'Elazig',
  'Manisa',
  'Sivas',
  'Gebze',
  'Balikesir',
  'Tarsus',
  'Kocaeli',
  'Erzurum',
  'Iskenderun',
  'Osmaniye',
  'Corlu',
  'Kutahya',
  'Nazilli',
  'Antakya',
  'Sisli',
  'Muratpasa',
  'Aydin',
  'Usak',
  'Karabuk',
  'Karaman',
  'Nigde',
  'Ordu',
  'Erzincan',
  'Atasehir',
  'Esenyurt',
  'Silivri',
  'Gebze',
  'Sultangazi',
  'Basaksehir',
  'Yozgat',
  'Bagcilar',
  'Gungoren',
  'Sultanbeyli',
  'Aksaray',
  'Inegol',
  'Tokat',
  'Cankaya',
  'Umraniye',
  'Batman',
  'Baglar',
  'Esenyurt',
  'Bahcelievler',
  'Van',
  'Bakirkoy',
  'Siirt',
  'Kusadasi',
  'Orhangazi',
  'Karakoy',
  'Buyukcekmece',
  'Samandira',
  'Mardin',
  'Ceyhan',
  'Sarigerme',
  'Isparta',
  'Bolu',
  'Afyonkarahisar',
  'Rize',
  'Zonguldak',
  'Duzce',
  'Torbali',
  'Corum',
  'Gerede',
  'Edirne',
  'Giresun',
  'Karsiyaka',
  'Ayvalik',
  'Milas',
  'Didim',
  'Marmaris',
  'Mudanya',
  'Urla',
  'Burhaniye',
  'Beylikduzu',
  'Tire',
  'Kirklareli',
  'Seferihisar',
  'Yenisehir',
  'Belek',
  'Dalaman',
  'Gocek',
  'Kemer',
  'Side',
  'Demre',
  'Ortaca',
  'Kumluca',
  'Ayvacik',
  'Golturkbuku',
  'Cesme',
  'Avsallar',
  'Kayakoy',
  'Pamukkale',
  'Foca',
  'Hisaronu',
  'Kas',
  'Koycegiz',
  'Selimiye',
  'Icmeler',
  'Guzelcamli',
  'Gocek',
  'Torba',
  'Altinkum',
  'Ovacik',
  'Bogazkent',
  'Datca',
  'Kumkoy',
  'Bitez',
  'Ortakent',
  'Kalkan',
  'Marmaris',
  'Sogut',
  'Mesudiye',
  'Gumbet',
  'Oren',
  'Turunc',
  'Bozburun',
  'Bodrum',
  'Oludeniz',
  'Ciftlik',
  'Gumusluk',
  'Turgutreis',
  'Gokova',
  'Akyaka',
  'Fethiye',
  'Mazi',
  'Kayakoy',
  'Gokbel',
  'Yaniklar',
  'Gulluk',
  'Uzumlu',
  'Camyuva',
  'Kucukkuyu',
  'Karacabey',
  'Mustafakemalpasa',
  'Bozcaada',
  'Patara',
  'Faraly'

  // Add more cities here
];
