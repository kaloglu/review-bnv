import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollModel {
  late String title;
  late String description;
  late String image;
  late DateTime enrollDate; // Use DateTime type for enrollDate
  late String ticketid;
  late String raffleid;
  late String uid;
  late int enrollmentCount;

  EnrollModel({
    required this.enrollDate,
    required this.ticketid,
    required this.raffleid,
    required this.uid,
    required this.title,
    required this.description,
    required this.image,
    required this.enrollmentCount,
  });

  EnrollModel.fromJson(Map<dynamic, dynamic> json) {
    enrollDate = (json['enrollDate'] as Timestamp)
        .toDate(); // Convert Timestamp to DateTime
    ticketid = json['ticketid'] ?? '';
    raffleid = json['raffleid'] ?? '';
    title = json['title'] ?? '';
    description = json['description'] ?? '';
    image = json['image'] ?? '';
    enrollmentCount = json['enrollmentCount'] ?? 0;
    uid = json['uid'] ?? '';
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = <dynamic, dynamic>{};
    data['enrollDate'] = enrollDate;
    data['ticketid'] = ticketid;
    data['raffleid'] = raffleid;
    data['title'] = title;
    data['description'] = description;
    data['enrollmentCount'] = enrollmentCount;
    data['image'] = image;
    data['uid'] = uid;
    return data;
  }
}
