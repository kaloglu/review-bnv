import 'package:cloud_firestore/cloud_firestore.dart';

// class AttendeeslModel {
//   late DateTime createDate; // Use DateTime type for createDate
//
//   late String uid;
//
//   AttendeeslModel({
//     required this.createDate,
//     required this.uid,
//   });
//
//   AttendeeslModel.fromJson(Map<dynamic, dynamic> json) {
//     createDate = (json['createDate'] as Timestamp)
//         .toDate(); // Convert Timestamp to DateTime
//
//     uid = json['uid'] ?? '';
//   }
//
//   Map<dynamic, dynamic> toJson() {
//     final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
//     data['createDate'] = createDate;
//
//     data['uid'] = uid;
//     return data;
//   }
// }
class AttendeeslModel {
  late DateTime createDate;
  late String uid;
  late String productId; // Include the productId field in the Attendees model

  AttendeeslModel({
    required this.createDate,
    required this.uid,
    required this.productId,
  });

  AttendeeslModel.fromJson(Map<dynamic, dynamic> json) {
    createDate = (json['createDate'] as Timestamp).toDate();
    uid = json['uid'] ?? '';
    productId = json['productId'] ?? ''; // Initialize productId
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['createDate'] = createDate;
    data['uid'] = uid;
    data['productId'] = productId; // Include productId in the toJson method
    return data;
  }
}

