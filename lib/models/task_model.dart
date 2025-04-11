import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  String? id;
  String? uid;
  String title;
  String? description;
  String status;
  List<String> attachments;
  DateTime createdDate;
  DateTime? dueDate;

  TaskItem({
    this.id,
    this.uid,
    required this.title,
    this.description,
    required this.status,
    this.attachments = const [],
    required this.createdDate,
    this.dueDate,
  });
  factory TaskItem.fromMap(Map<String, dynamic> json) {
    return TaskItem(
      id: json["id"],
      uid: json["uid"],
      title: json["title"],
      description: json["description"],
      status: json["status"],
      attachments: json["attachments"] == null ? [] : List<String>.from(json["attachments"].map((e) => e.toString())),
      createdDate: json["createdDate"] is Timestamp
          ? (json['createdDate'] as Timestamp).toDate()
          : DateTime.parse(json["createdDate"]),
      dueDate: json["dueDate"] == null
          ? null
          : json['dueDate'] is Timestamp
              ? (json['dueDate'] as Timestamp).toDate()
              : DateTime.tryParse(json['dueDate']),
    );
  }
  Map<String, dynamic> toJson({bool firebaseFormat = false}) {
    return {
      "id": id,
      "uid": uid,
      "title": title,
      "description": description,
      "status": status,
      "attachments": attachments,
      "createdDate": firebaseFormat ? Timestamp.fromDate(createdDate) : createdDate.toIso8601String(),
      "dueDate": firebaseFormat
          ? dueDate == null
              ? null
              : Timestamp.fromDate(dueDate!)
          : dueDate?.toIso8601String(),
    };
  }
}
