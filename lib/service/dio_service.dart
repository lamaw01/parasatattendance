import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/event_model.dart';
import '../model/log_model.dart';
import '../model/version_model.dart';

class DioService {
  static const String _serverUrl = 'https://konek.parasat.tv:53000/';

  static const String downloadLink = '$_serverUrl/download/attendance.apk';

  final _dio = Dio(
    BaseOptions(
      baseUrl: '$_serverUrl/attendance_api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: <String, String>{
        'Accept': '*/*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  );

  Future<LogModel> insertLog({required String employeeId}) async {
    Response response = await _dio.post(
      '/insert_attendance.php',
      data: {'employee_id': employeeId},
    );
    debugPrint(response.data.toString());
    return logModelFromJson(json.encode(response.data));
  }

  Future<VersionModel> getAppVersion() async {
    Response response = await _dio.get('/get_app_version.php');
    debugPrint(response.data.toString());
    return versionModelFromJson(json.encode(response.data));
  }

  Future<EventModel> getLatestEvent() async {
    Response response = await _dio.get('/get_latest_event.php');
    debugPrint(response.data.toString());
    return eventModelFromJson(json.encode(response.data));
  }

  Future<void> insertDeviceLog({
    required String id,
    required String logTime,
    required String address,
    required String latlng,
    required String version,
  }) async {
    await _dio.post(
      '/insert_device_log.php',
      data: {
        "device_id": id,
        "log_time": logTime,
        "address": address,
        "latlng": latlng,
        "version": version,
        "app_name": 'attendance'
      },
    );
  }
}
