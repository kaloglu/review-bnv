class Images {
late  String path;
 late String type;

  Images({required this.path, required this.type});

  Images.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = path;
    data['type'] = type;
    return data;
  }
}