import 'package:cihan_app/Domain/models/product_info_model.dart';
import 'package:cihan_app/Domain/models/rules_model.dart';
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
  late List<String> tags;
  late String title;

  ProductModel({
    required this.category,
    required this.description,
    required this.id,
    required this.image,
    required this.productInfo,
    required this.requiredTickets,
    required this.rules,
    required this.startDate,
    required this.endDate,
    required this.tags,
    required this.title,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    description = json['description'];
    id = json['id'];
    image = json['image'];
    productInfo = ProductInfo.fromJson(json['productInfo']);
    requiredTickets = json['requiredTickets'];
    rules = Rules.fromJson(json['rules']);
    title = json['title'];
    startDate = json['startDate'] as Timestamp;
    endDate = json['endDate'] as Timestamp;
    tags = List<String>.from(json['tags'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['description'] = description;
    data['id'] = id;
    data['image'] = image;
    final productInfo = this.productInfo;
    data['productInfo'] = productInfo.toJson();
    data['requiredTickets'] = requiredTickets;
    final rules = this.rules;
    data['rules'] = rules.toJson();
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['tags'] = tags;
    data['title'] = title;
    return data;
  }

  static ProductModel fromMap(Map<String, dynamic> data) {
    return ProductModel(
      category: data['category'],
      description: data['description'],
      id: data['id'],
      image: data['image'],
      productInfo: ProductInfo.fromJson(data['productInfo']),
      requiredTickets: data['requiredTickets'],
      rules: Rules.fromJson(data['rules']),
      startDate: data['startDate'] as Timestamp,
      endDate: data['endDate'] as Timestamp,
      tags: List<String>.from(data['tags'] ?? []),
      title: data['title'],
    );
  }
}
