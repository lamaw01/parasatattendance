import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:parasatattendance/model/qr_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/insert_log_riverpod.dart';
import '../data/latest_event_riverpod.dart';
import '../data/mobile_scanner_riverpod.dart';
import '../data/parsed_qr_riverpod.dart';
import '../data/scan_mode_riverpod.dart';
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
  Future<void> showScannedQr(String? qr) async {
    QrModel? qrModel;
    try {
      qrModel = ref.read(parsedQrDataProvider(qr!));
    } catch (e) {
      debugPrint('$e');
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (qrModel != null) ...[
                  RichText(
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: 'Name: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                      children: [
                        TextSpan(
                          text: qrModel.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 18.0,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: 'ID#: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                      children: [
                        TextSpan(
                          text: qrModel.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 18.0,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Unkown QR:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        qr.toString(),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();

    const String title = 'UC-1 Attendance';
    const double iconSplash = 26.0;
    final MobileScannerController camera = ref.read(mobileScannerProvider);
    final scanMode = ref.watch(scanModeStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            splashRadius: iconSplash,
            iconSize: 30.0,
            icon: scanMode
                ? const Text(
                    'ATD',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(Icons.live_help_outlined),
            onPressed: () {
              ref.read(scanModeStateProvider.notifier).state = !scanMode;
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            iconSize: 30.0,
            splashRadius: iconSplash,
            onPressed: () async {
              await ref.read(latestEventProvider.notifier).getLatestEvent();
              final latestEvent = ref.read(latestEventProvider);
              // ignore: use_build_context_synchronously
              DialogService().appVersionDialog(context,
                  version: latestEvent.version, event: latestEvent.event);
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
              log('firstQr ${barcodes.first.rawValue}');

              if (ref.watch(scanModeStateProvider)) {
                showScannedQr(firstQr);
              } else {
                ref.read(insertLogFutureProvider(firstQr!).future).then((data) {
                  final QrModel qrModel =
                      ref.read(parsedQrDataProvider(firstQr));
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
                      name: error.toString(), message: 'Error Logging In');
                });
              }
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
          if (scanMode) ...[
            Positioned(
              top: 30.0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.195,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.amber[500],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Center(
                  child: Text(
                    'Scan Mode\nTest your QR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 42.0,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.white,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
