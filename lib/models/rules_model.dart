class Rules {
 late int maxAttendByUser;
 late int maxAttendee;

  Rules({required this.maxAttendByUser, required this.maxAttendee});

  Rules.fromJson(Map<String, dynamic> json) {
    maxAttendByUser = json['maxAttendByUser'];
    maxAttendee = json['maxAttendee'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['maxAttendByUser'] = maxAttendByUser;
    data['maxAttendee'] = maxAttendee;
    return data;
  }
}