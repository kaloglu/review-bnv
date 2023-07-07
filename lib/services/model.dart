// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String title;
  String description;
  Timestamp startDate;
  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
  });


  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    Timestamp? startDate
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate as DateTime),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      startDate: map['startDate'].toDate(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) => ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ProductModel(id: $id, title: $title, description: $description, startDate: $startDate)';

  @override
  bool operator ==(covariant ProductModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.title == title &&
      other.description == description &&
      other.startDate == startDate;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ description.hashCode ^ startDate.hashCode;
}
