// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parasatattendance/view/home_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/address_riverpod.dart';
import '../data/app_version.dart';
import '../data/device_info_riverpod.dart';
import '../service/dio_service.dart';
import '../static/color_static.dart';

class LoadingView extends ConsumerStatefulWidget {
  const LoadingView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoadingViewState();
}

class _LoadingViewState extends ConsumerState<LoadingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(addressProvider.notifier).getPosition();
      await ref.read(appUpdatedProvider.notifier).getAppVersion();
      await ref.read(deviceInfoProvider.notifier).getDeviceInfo();

      final appUpdatedModel = ref.read(appUpdatedProvider);
      if (appUpdatedModel.updated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const HomeView(),
          ),
        );
      } else {
        newVersionDialog(
            packageVersion: appUpdatedModel.localVersion,
            databaseVersion: appUpdatedModel.databaseVersion);
      }
    });
  }

  void newVersionDialog({
    required String packageVersion,
    required String databaseVersion,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Out of date'),
          content: Text(
              'Current version $packageVersion is out of date. Please update to version $databaseVersion.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Download new version'),
              onPressed: () {
                launchUrl(Uri.parse(DioService.downloadLink),
                    mode: LaunchMode.externalApplication);
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: ColorStatic.kMainColor,
      body: Center(
        child: Card(
          child: SizedBox(
            height: 75.0,
            width: 200.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Loading...'),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
