import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:parasatattendance/model/qr_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/app_version_riverpod.dart';
import '../data/insert_log_riverpod.dart';
import '../data/latest_event_riverpod.dart';
import '../data/mobile_scanner_riverpod.dart';
import '../data/parsed_qr_riverpod.dart';
import '../service/dialog_service.dart';
import '../service/toast_service.dart';
import '../widget/camera_border_widget.dart';
import '../widget/loading_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();

    const String title = 'Parasat Attendance';
    const double iconSplash = 26.0;
    final MobileScannerController camera = ref.read(mobileScannerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            iconSize: 30.0,
            splashRadius: iconSplash,
            onPressed: () {
              ref.read(appPackageInfoFutureProvider.future).then((version) {
                ref.read(latestEventFutureProvider.future).then(
                  (event) {
                    DialogService().appVersionDialog(context,
                        title: 'Attendance ${version.version}',
                        event: event.eventName);
                  },
                );
              });
            },
          ),
          IconButton(
            splashRadius: iconSplash,
            icon: ValueListenableBuilder(
              valueListenable: camera.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 30.0,
            onPressed: () => camera.toggleTorch(),
          ),
          IconButton(
            splashRadius: iconSplash,
            icon: ValueListenableBuilder(
              valueListenable: camera.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 30.0,
            onPressed: () => camera.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: camera,
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              String? firstQr = barcodes.first.rawValue;
              debugPrint('firstQr ${barcodes.first.rawValue}');

              final QrModel qrModel = ref.read(parsedQrDataProvider(firstQr!));

              ref.read(insertLogFutureProvider(firstQr).future).then((data) {
                switch (data.message) {
                  case 'ok':
                    ToastService().showToast(context,
                        name: qrModel.name, message: 'Succesfully Logged!');
                  case 'already logged':
                    ToastService().showToast(context,
                        name: qrModel.name, message: 'Already Logged!');
                }
              }).onError((error, stackTrace) {
                log('$error $stackTrace');
                ToastService().showToast(context,
                    name: null, message: 'Error Logging In');
              });
            },
            errorBuilder: (ctx, exception, _) {
              debugPrint('errorBuilder');
              String errorCode = exception.errorCode.name;
              camera.stop();
              camera.start();
              return SizedBox(
                child: Center(
                  child: Text(
                    'Error Initializing Camera $errorCode',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            placeholderBuilder: (ctx, widget) {
              return const SizedBox(
                child: LoadingWidget(),
              );
            },
          ),
          SizedBox(
            height: 200.0,
            width: 200.0,
            child: CustomPaint(
              foregroundPainter: CameraBorderWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
