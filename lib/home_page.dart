import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';

import 'models/config_model.dart';
import 'webview/web_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isLoading = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    GetIt getIt = GetIt.instance;
    var config = getIt.get<ConfigModel>();

    config.selectNotificationStream.close();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    GetIt getIt = GetIt.instance;
    var config = getIt.get<ConfigModel>();

    if (state == AppLifecycleState.resumed) {
      config.isOpen = true;
      _resumedApp();
    } else {
      config.isOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    GetIt getIt = GetIt.instance;
    var config = getIt.get<ConfigModel>();

    return Scaffold(
      key: scaffoldKey,
      body: WebViewPage(
        voidCallback: () {
          setState(() {
            isLoading = false;
          });
        },
      ),
      bottomNavigationBar: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : null,
      resizeToAvoidBottomInset: defaultTargetPlatform == TargetPlatform.android,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF119c72),
        onPressed: () {
          config.controller!.reload();
        },
        mini: true,
        shape: const CircleBorder(),
        child: const Icon(Icons.refresh, color: Colors.white, size: 24),
      ),
    );
  }

  void _resumedApp() async {
    GetIt getIt = GetIt.instance;
    var config = getIt.get<ConfigModel>();

    if (config.notificationUrl != "") {
      var url = config.notificationUrl;
      config.notificationUrl = "";

      await config.controller?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url)),
      );
    } else {
      await config.controller?.reload();
    }
  }
}
