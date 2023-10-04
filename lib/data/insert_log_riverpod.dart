import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/log_model.dart';
import '../model/qr_model.dart';
import 'dio_service_riverpod.dart';

final insertLogFutureProvider =
    FutureProvider.family.autoDispose<LogModel, String>(
  (ref, qrData) {
    var dataParsed = qrModelFromJson(qrData);
    var dioProvider = ref.watch(dioServiceProvider);
    return dioProvider.insertLog(employeeId: dataParsed.id);
  },
);
