import 'image_model.dart';

class ProductInfo {
  late int count;
  late List<Images> images;
  late String name;
  late String unit;
  late double unitPrice;

  ProductInfo(
      {required this.count,
      required this.images,
      required this.name,
      required this.unit,
      required this.unitPrice});

  ProductInfo.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['images'] != null) {
      if (json['images'] is List<dynamic>) {
        images = (json['images'] as List<dynamic>)
            .map((v) => Images.fromJson(v))
            .toList();
      } else {
        images = [];
      }
    } else {
      images = [];
    }
    name = json['name'];
    unit = json['unit'];
    unitPrice = json['unitPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['images'] = images.map((v) => v.toJson()).toList();
    data['name'] = name;
    data['unit'] = unit;
    data['unitPrice'] = unitPrice;
    return data;
  }
}
