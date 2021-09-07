// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class Notes {
  String title;
  String description;
  String? id;
  Timestamp createTime;

  Notes(
      {required this.title,
      required this.description,
      required this.id,
      required this.createTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['id'] = id;
    data['createTime'] = createTime;
    return data;
  }

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      title: json['title'],
      description: json['description'],
      id: json['id'],
      createTime: json['createTime'],
    );
  }
}
