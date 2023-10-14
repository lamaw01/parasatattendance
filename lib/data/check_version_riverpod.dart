import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../service/dio_service.dart';

final appUpdatedProvider =
    NotifierProvider<AppUpdated, AppUpdatedModel>(AppUpdated.new);

class AppUpdated extends Notifier<AppUpdatedModel> {
  @override
  AppUpdatedModel build() {
    return AppUpdatedModel(localVersion: '1.0.0', databaseVersion: '1.0.0');
  }

  Future<void> getDatabaseVersion() async {
    try {
      final localVersion = await PackageInfo.fromPlatform();
      final databaseVersion = await DioService().getAppVersion();
      final version1 = localVersion.version.replaceAll(".", "").trim();
      final version2 = databaseVersion.version.replaceAll(".", "").trim();
      if (int.parse(version1) < int.parse(version2)) {
        state = AppUpdatedModel(
          localVersion: localVersion.version,
          databaseVersion: databaseVersion.version,
          updated: false,
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }
}

class AppUpdatedModel {
  String localVersion;
  String databaseVersion;
  bool updated;

  AppUpdatedModel({
    required this.localVersion,
    required this.databaseVersion,
    this.updated = true,
  });
}
