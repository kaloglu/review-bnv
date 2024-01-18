import 'package:cloud_firestore/cloud_firestore.dart';

class AttendeesModel {
  late DateTime? createDate;
  late String uid;
  late String? raffleId; // Include the raffleId field in the Attendees model
  //late String deviceToken;
  AttendeesModel({
    required this.createDate,
    required this.uid,
    required this.raffleId,
    //required this.deviceToken,
  });

  AttendeesModel.fromJson(Map<dynamic, dynamic> json) {
    createDate = (json['createDate'] as Timestamp).toDate();
    uid = json['uid'] ?? '';
    //deviceToken = json['deviceToken'] ?? '';
    raffleId = json['raffleId'] ?? ''; // Initialize raffleId
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['createDate'] = createDate;
    data['uid'] = uid;
    //data['deviceToken'] = deviceToken;
    data['raffleId'] = raffleId; // Include raffleId in the toJson method
    return data;
  }
}


