import 'package:cihan_app/models/product_info_model.dart';
import 'package:cihan_app/models/rules_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  late String category;
  late String description;
  late String id;
  late String image;
  late ProductInfo productInfo;
  late int requiredTickets;
  late Rules rules;
  late Timestamp startDate;
  late Timestamp endDate;

  late Timestamp resultDate;
  late String title;

  ProductModel(
      {required this.category,
      required this.description,
      //  required this.endDate,
      required this.id,
      required this.image,
      required this.productInfo,
      required this.requiredTickets,
      required this.rules,
      required this.startDate,
      required this.endDate,
      required this.resultDate,
      required this.title});

  ProductModel.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    description = json['description'];
   // endDate = json['endDate'] as EndDate;
    id = json['id'];
    image = json['image'];
    productInfo = ProductInfo.fromJson(json['productInfo']);
    requiredTickets = json['requiredTickets'];
    rules = json['rules'] as Rules;
    title = json['title'];
    startDate = json['startDate'] as Timestamp;
    endDate = json['endDate'] as Timestamp;
    resultDate = json['resultDate'] as Timestamp;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = category;
    data['description'] = description;
    // if (this.endDate != null) {
    //   data['endDate'] = this.endDate.toJson();
    // }
    data['id'] = id;
    data['image'] = image;
    if (productInfo != null) {
      data['productInfo'] = productInfo.toJson();
    }
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['endDate'] = resultDate;

    data['requiredTickets'] = requiredTickets;
    if (rules != null) {
      data['rules'] = rules.toJson();
    }
    // if (this.startDate != null) {
    //   data['startDate'] = this.startDate.toJson();
    // }
    data['title'] = title;
    return data;
  }
}








