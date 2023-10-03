import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

final mobileScannerProvider = Provider<MobileScannerController>((ref) {
  return MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 4500,
    facing: CameraFacing.front,
    formats: [BarcodeFormat.qrCode],
  );
});
