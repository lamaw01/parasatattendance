// To parse this JSON data, do
//
//     final eventModel = eventModelFromJson(jsonString);

import 'dart:convert';

EventModel eventModelFromJson(String str) =>
    EventModel.fromJson(json.decode(str));

String eventModelToJson(EventModel data) => json.encode(data.toJson());

class EventModel {
  int eventId;
  String eventName;

  EventModel({
    required this.eventId,
    required this.eventName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        eventId: json["event_id"],
        eventName: json["event_name"],
      );

  Map<String, dynamic> toJson() => {
        "event_id": eventId,
        "event_name": eventName,
      };
}
