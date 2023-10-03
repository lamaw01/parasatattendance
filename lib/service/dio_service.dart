import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/log_model.dart';

class DioService {
  static const String _serverUrl = 'http://103.62.153.74:53000/attendance_api';

  final _dio = Dio(
    BaseOptions(
      baseUrl: _serverUrl,
      connectTimeout: const Duration(seconds: 5),
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
}
