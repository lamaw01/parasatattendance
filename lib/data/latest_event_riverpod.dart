import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../service/dio_service.dart';

final latestEventProvider =
    NotifierProvider<LatestEvent, LatestEventModel>(LatestEvent.new);

class LatestEvent extends Notifier<LatestEventModel> {
  @override
  LatestEventModel build() {
    return LatestEventModel(version: '1.0.0', event: '');
  }

  Future<void> getLatestEvent() async {
    try {
      if (state.version == '1.0.0') {
        final localVersion = await PackageInfo.fromPlatform();
        state.version = localVersion.version;
      }
      final latestEvent = await DioService().getLatestEvent();
      state.event = latestEvent.eventName;
    } catch (e) {
      log(e.toString());
      state.event = e.toString();
    }
  }
}

class LatestEventModel {
  String version;
  String event;

  LatestEventModel({
    required this.version,
    required this.event,
  });
}
