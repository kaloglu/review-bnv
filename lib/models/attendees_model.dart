import 'package:cloud_firestore/cloud_firestore.dart';

class AttendeesModel {
  late DateTime createDate;
  late String uid;
  late String productId; // Include the productId field in the Attendees model

  AttendeesModel({
    required this.createDate,
    required this.uid,
    required this.productId,
  });

  AttendeesModel.fromJson(Map<dynamic, dynamic> json) {
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
