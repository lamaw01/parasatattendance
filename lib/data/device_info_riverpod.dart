import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../service/dio_service.dart';
import 'address_riverpod.dart';
import 'app_version.dart';

final deviceInfoProvider =
    NotifierProvider<DeviceInfoProvider, String>(DeviceInfoProvider.new);

class DeviceInfoProvider extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  int _sixDigitCode = 000000;

  Future<void> getDeviceInfo() async {
    try {
      await DeviceInfoPlugin().androidInfo.then((result) {
        state = "${result.brand}:${result.product}:${result.id}";
      });
    } catch (e) {
      log(e.toString());
    } finally {
      await checkCode();
    }
  }

  // check if device has generate code
  Future<void> checkCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? code = prefs.getInt('code');
      if (code != null) {
        _sixDigitCode = code;
        state = "$state:$_sixDigitCode";
      } else {
        generateCode();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      await insertDeviceLog();
    }
  }

  // generate 6 digit code and store in sharedpref
  Future<void> generateCode() async {
    try {
      var random = math.Random();
      var generatedCode = random.nextInt(900000) + 100000;
      _sixDigitCode = generatedCode;
      log("$_sixDigitCode");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('code', _sixDigitCode);
      state = "$state:$_sixDigitCode";
    } catch (e) {
      log(e.toString());
    }
  }

  // insert device log to database
  Future<void> insertDeviceLog() async {
    try {
      final addressModel = ref.read(addressProvider);
      final appUpdatedModel = ref.read(appUpdatedProvider);
      await DioService().insertDeviceLog(
        id: state,
        logTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        address: addressModel.address,
        latlng: addressModel.latlng,
        version: appUpdatedModel.localVersion,
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
