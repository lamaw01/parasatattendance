import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parasatattendance/view/home_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_version_database_riverpod.dart';
import '../data/app_version_riverpod.dart';
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
    ref.read(appPackageInfoFutureProvider.future).then((data1) {
      ref.read(appVersionFutureProvider.future).then((data2) {
        final packageVersion = data1.version.replaceAll(".", "").trim();
        final databaseVersion = data2.version.replaceAll(".", "").trim();
        log('${data1.version} ${data2.version}');
        if (int.parse(packageVersion) < int.parse(databaseVersion)) {
          newVersionDialog(
              packageVersion: data1.version, databaseVersion: data2.version);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const HomeView(),
            ),
          );
        }
      });
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
