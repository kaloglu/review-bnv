


import 'package:cloud_firestore/cloud_firestore.dart';

class TicketModel {
  late DateTime createDate; // Use DateTime type for createDate
  late String earn;
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
    earn = json['earn'] ?? '0';
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
