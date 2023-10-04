import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/version_model.dart';
import 'dio_service_riverpod.dart';

final appVersionFutureProvider = FutureProvider.autoDispose<VersionModel>(
  (ref) {
    var dioProvider = ref.watch(dioServiceProvider);
    return dioProvider.getAppVersion();
  },
);
