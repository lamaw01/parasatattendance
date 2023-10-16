import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/log_model.dart';
import '../model/qr_model.dart';
import '../service/dio_service.dart';
import 'parsed_qr_riverpod.dart';

class LogWithQr {
  LogModel logModel;
  QrModel qrModel;

  LogWithQr({required this.logModel, required this.qrModel});
}

final insertLogFutureProvider =
    FutureProvider.family.autoDispose<LogModel, String>(
  (ref, qrData) {
    var dataParsed = ref.read(parsedQrDataProvider(qrData));
    return DioService().insertLog(employeeId: dataParsed.id);
  },
);
