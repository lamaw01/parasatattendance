import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/qr_model.dart';

final parsedQrDataProvider = Provider.family<QrModel, String>(
  (ref, qrData) {
    var dataParsed = qrModelFromJson(qrData);
    return dataParsed;
  },
);
