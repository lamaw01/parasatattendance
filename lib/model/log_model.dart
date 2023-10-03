// To parse this JSON data, do
//
//     final logModel = logModelFromJson(jsonString);

import 'dart:convert';

LogModel logModelFromJson(String str) => LogModel.fromJson(json.decode(str));

String logModelToJson(LogModel data) => json.encode(data.toJson());

class LogModel {
  bool success;
  String message;

  LogModel({
    required this.success,
    required this.message,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) => LogModel(
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
      };
}
