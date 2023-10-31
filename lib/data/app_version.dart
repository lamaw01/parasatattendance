import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../service/dio_service.dart';

final appUpdatedProvider =
    NotifierProvider<AppVersionProvider, AppUpdatedModel>(
        AppVersionProvider.new);

class AppVersionProvider extends Notifier<AppUpdatedModel> {
  @override
  AppUpdatedModel build() {
    return AppUpdatedModel(localVersion: '1.0.0', databaseVersion: '1.0.0');
  }

  Future<void> getAppVersion() async {
    try {
      final localVersion = await PackageInfo.fromPlatform();
      state.localVersion = localVersion.version;
      final databaseVersion = await DioService().getAppVersion();
      state.databaseVersion = databaseVersion.version;
      log('${state.localVersion} ${state.databaseVersion}');
      final version1 = state.localVersion.replaceAll(".", "").trim();
      final version2 = state.databaseVersion.replaceAll(".", "").trim();
      if (int.parse(version1) < int.parse(version2)) {
        state.updated = false;
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
