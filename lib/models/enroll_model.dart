import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollModel {
  late DateTime enrollDate; // Use DateTime type for enrollDate
  late String ticketid;
  late String raffleid;
  late String uid;

  EnrollModel({
    required this.enrollDate,
    required this.ticketid,
    required this.raffleid,
    required this.uid,
  });

  EnrollModel.fromJson(Map<dynamic, dynamic> json) {
    enrollDate = (json['enrollDate'] as Timestamp)
        .toDate(); // Convert Timestamp to DateTime
    ticketid = json['ticketid'] ?? '';
    raffleid = json['raffleid'] ?? '';
    uid = json['uid'] ?? '';
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['enrollDate'] = enrollDate;
    data['ticketid'] = ticketid;
    data['raffleid'] = raffleid;
    data['uid'] = uid;
    return data;
  }
}
