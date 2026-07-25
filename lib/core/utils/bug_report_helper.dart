import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_logger.dart';

class BugReportHelper {
  final DeviceInfoPlugin _deviceInfo;
  final AppLogger _logger;

  BugReportHelper({DeviceInfoPlugin? deviceInfo, AppLogger? logger})
      : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _logger = logger ?? appLogger;

  Future<Map<String, String>> collectDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    String os;
    String osVersion;
    String deviceModel;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = await _deviceInfo.androidInfo;
      os = 'Android';
      osVersion = android.version.release;
      deviceModel = '${android.manufacturer} ${android.model}';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = await _deviceInfo.iosInfo;
      os = 'iOS';
      osVersion = ios.systemVersion;
      deviceModel = '${ios.name} ${ios.modelName}';
    } else {
      os = defaultTargetPlatform.name;
      osVersion = 'unknown';
      deviceModel = 'unknown';
    }

    return {
      'app_version': appVersion,
      'os': os,
      'os_version': osVersion,
      'device': deviceModel,
    };
  }

  String buildLogs({int maxLines = 80}) {
    final lines = _logger.exportLogs().split('\n');
    final recent = lines.length > maxLines ? lines.sublist(lines.length - maxLines) : lines;
    return recent.join('\n');
  }

  Future<bool> openBugReport({String? description}) async {
    try {
      final info = await collectDeviceInfo();
      final logs = buildLogs(maxLines: 20);

      final title = '[Mobile Bug] ${description ?? "Bug report from app"}';
      final os = '${info['os']} ${info['os_version']}';
      final version = 'App ${info['app_version']} / ${info['device']}';

      final params = {
        'template': 'mobile-bug-report.yml',
        'title': title,
        'os': os,
        'version': version,
        'description': description ?? '',
        'logs': logs,
      };

      final query = params.entries
          .where((e) => e.value.isNotEmpty)
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final url = Uri.parse(
        'https://github.com/nmwael/subvocal/issues/new?$query',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
