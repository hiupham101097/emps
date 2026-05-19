import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final VoidCallback voidCallback;

  const WebViewPage({super.key, required this.voidCallback});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();

  final String defaultUrl = 'https://boss.empos.vn';

  late InAppWebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: InAppWebView(
          key: webViewKey,

          initialUrlRequest: URLRequest(url: WebUri(defaultUrl)),

          initialSettings: InAppWebViewSettings(
            isInspectable: kDebugMode,

            javaScriptEnabled: true,

            transparentBackground: false,

            useWideViewPort: true,
            loadWithOverviewMode: true,

            supportZoom: false,
            builtInZoomControls: false,
            displayZoomControls: false,

            textZoom: 100,

            preferredContentMode: UserPreferredContentMode.MOBILE,

            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,

            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,

            iframeAllowFullscreen: true,

            allowUniversalAccessFromFileURLs: true,

            useShouldInterceptRequest: false,
            
            cacheEnabled: true,
            cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
            hardwareAcceleration: true,
            domStorageEnabled: true,
            databaseEnabled: true,

            userAgent:
                "Mozilla/5.0 (Linux; Android 13; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36",
          ),

          onWebViewCreated: (controller) {
            webViewController = controller;
          },

          onLoadStart: (controller, url) {
            debugPrint("START: $url");
          },

          onLoadStop: (controller, url) async {
            debugPrint("STOP: $url");

            await controller.evaluateJavascript(
              source: """
                (function() {

                  var oldMeta = document.querySelector('meta[name="viewport"]');

                  if (oldMeta) {
                    oldMeta.remove();
                  }

                  var meta = document.createElement('meta');

                  meta.name = 'viewport';

                  meta.content =
                    'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';

                  document.getElementsByTagName('head')[0]
                    .appendChild(meta);

                  document.body.style.zoom = "1.0";

                  document.body.style.webkitTextSizeAdjust = "100%";

                })();
              """,
            );

            widget.voidCallback();
          },

          onConsoleMessage: (controller, consoleMessage) {
            debugPrint("Console: ${consoleMessage.message}");
          },

          onReceivedError: (controller, request, error) {
            debugPrint("ERROR: ${error.description}");
          },

          onReceivedHttpError: (controller, request, response) {
            debugPrint("HTTP ERROR: ${response.statusCode}");
          },
        ),
      ),
    );
  }
}
