import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  // Singleton pattern
  static final UrlLauncherService _instance = UrlLauncherService._internal();

  factory UrlLauncherService() {
    return _instance;
  }

  UrlLauncherService._internal();

  /// Launches a URL (http, tel, mailto, etc.)
  Future<void> launchUrlExternal(String urlString,{bool isNewTab = true}) async {
    final Uri url = Uri.parse(urlString);

    // if (await canLaunchUrl(url)) {
    //   final bool launched = await launchUrl(
    //     url,
    //     mode: LaunchMode.externalApplication,
    //   );

    //   if (!launched) {
    //     throw Exception("Could not launch URL: $urlString");
    //   }
    // } else {
    //   throw Exception("URL not valid or not supported: $urlString");
    // }
    if (kIsWeb) {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: isNewTab ? '_blank' : '_self',
      )) {
        throw Exception('Could not launch $url');
      }
    } else if (Platform.isAndroid) {
      if (!await launchUrl(url,
          mode: LaunchMode.externalNonBrowserApplication)) {
        throw Exception('Could not launch $url');
      }
    } else if (Platform.isIOS) {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }
  }
}
