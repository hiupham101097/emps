import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final VoidCallback voidCallback;

  const WebViewPage({
    super.key,
    required this.voidCallback,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final String defaultUrl = 'https://boss.empos.vn';

  InAppWebViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(defaultUrl),
          ),

          initialSettings: InAppWebViewSettings(
            isInspectable: kDebugMode,

            javaScriptEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,

            // Tăng hiệu năng
            hardwareAcceleration: true,
            cacheEnabled: true,

            // KHÔNG dùng LOAD_CACHE_ELSE_NETWORK
            cacheMode: CacheMode.LOAD_DEFAULT,

            // Giảm lag render
            transparentBackground: false,

            // Zoom
            supportZoom: false,
            builtInZoomControls: false,
            displayZoomControls: false,

            // Video
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,

            // Quan trọng Android
            useWideViewPort: false,
            loadWithOverviewMode: false,

            // Tránh repaint nhiều
            disableHorizontalScroll: false,
            disableVerticalScroll: false,

            // KHÔNG custom userAgent nếu không cần
            // userAgent: ...
          ),

          onWebViewCreated: (webController) {
            controller = webController;
          },

          onLoadStop: (webController, url) async {
            debugPrint("Loaded: $url");

            // Chỉ inject CSS nhẹ
            await webController.evaluateJavascript(
              source: """
                document.body.style.webkitTextSizeAdjust='100%';
              """,
            );

            widget.voidCallback();
          },

          onConsoleMessage: (controller, msg) {
            debugPrint(msg.message);
          },

          onReceivedError: (controller, request, error) {
            debugPrint(error.description);
          },
        ),
      ),
    );
  }
}