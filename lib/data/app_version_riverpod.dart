import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appPackageInfoFutureProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});
