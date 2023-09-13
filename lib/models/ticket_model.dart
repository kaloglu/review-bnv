// // ignore_for_file: public_member_api_docs, sort_constructors_first
//
// class TicketModel {
//   late String createDate;
//   late String earn;
//   late String source;
//   late int remain;
//   // late String country;
//
//   late String uid;
//
//   TicketModel(
//       {required this.createDate,
//       required this.earn,
//       required this.source,
//       // required this.country,
//       required this.remain,
//       required this.uid});
//
//   TicketModel.fromJson(Map<dynamic, dynamic> json) {
//     createDate =
//         json['createDate'] ?? ''; // Provide a default empty string if null
//     earn = json['earn'] ?? ''; // Provide a default empty string if null
//     source = json['source'] ?? '';
//     // country = json['country'] ?? '';// Provide a default empty string if null
//     remain = json['remain'] ?? ''; // Provide a default empty string if null
//
//     uid = json['uid'] ?? ''; // Provide a default empty string if null
//   }
//
//   Map<dynamic, dynamic> toJson() {
//     final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
//     data['createDate'] = createDate;
//     data['earn'] = earn;
//     data['source'] = source;
//     // data ['country'] = country;
//     data['remain'] = remain;
//
//     data['uid'] = uid;
//     return data;
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  late DateTime createDate; // Use DateTime type for createDate
  late int earn;
  late String source;
  late int remain;
  late String uid;

  TicketModel({
    required this.createDate,
    required this.earn,
    required this.source,
    required this.remain,
    required this.uid,
  });

  TicketModel.fromJson(Map<dynamic, dynamic> json) {
    createDate = (json['createDate'] as Timestamp).toDate(); // Convert Timestamp to DateTime
    earn = json['earn'] ?? 0;
    source = json['source'] ?? '';
    remain = json['remain'] ?? 0; // Default to 0 if null
    uid = json['uid'] ?? '';
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['createDate'] = createDate;
    data['earn'] = earn;
    data['source'] = source;
    data['remain'] = remain;
    data['uid'] = uid;
    return data;
  }
}
