// ignore_for_file: public_member_api_docs, sort_constructors_first


class ProfileModel {
  late String fullname;
  late String email;
  late String phone;
  late String city;
  // late String country;
  late String address;
  late String profilepic;
  late String uid;

  ProfileModel({
    required this.fullname,
    required this.email,
    required this.phone,
    // required this.country,
    required this.city,
    required this.address,
    required this.profilepic,
    required this.uid
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    fullname = json['fullname'] ?? ''; // Provide a default empty string if null
    email = json['email'] ?? ''; // Provide a default empty string if null
    phone = json['phone'] ?? '';
    // country = json['country'] ?? '';// Provide a default empty string if null
    city = json['city'] ?? ''; // Provide a default empty string if null
    address = json['address'] ?? ''; // Provide a default empty string if null
    profilepic = json['profilepic'] ?? ''; // Provide a default empty string if null
    uid = json['uid'] ?? ''; // Provide a default empty string if null
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullname'] = fullname;
    data['email'] = email;
    data['phone'] = phone;
    // data ['country'] = country;
    data['city'] = city;
    data['address'] = address;
    data['profilepic'] = profilepic;
    data['uid'] = uid;
    return data;
  }
}
