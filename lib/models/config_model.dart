import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ConfigModel {
  late String? token;
  late String? firebaseToken;
  late String? deviceId;
  bool isFlutterLocalNotificationsInitialized = false;
  late StreamController<String?> selectNotificationStream;
  String notificationUrl = "";

  late InAppWebViewController? controller;
  late PlatformJavaScriptReplyProxy? replyProxy;

  bool isOpen = true;

  ConfigModel();
}
