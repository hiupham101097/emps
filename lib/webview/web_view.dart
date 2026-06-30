import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/config_model.dart';

class WebViewPage extends StatefulWidget {
  final VoidCallback voidCallback;

  const WebViewPage({super.key, required this.voidCallback});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final String defaultUrl = 'https://boss.empos.vn';

  InAppWebViewController? controller;
  late final Future<void> _prepareCameraPermissionFuture;

  String get initialUrl {
    final uri = Uri.parse(defaultUrl);
    return uri
        .replace(
          queryParameters: {
            ...uri.queryParameters,
            'flutter': '1',
            'isFlutter': '1',
            'webview': '1',
            'isWebView': '1',
            'platform': 'flutter',
            'app': 'boss_empos',
          },
        )
        .toString();
  }

  static const String _permissionTextPatch = """
    (() => {
      const patch = () => {
        const root = document.body || document.documentElement;
        if (!root) {
          window.requestAnimationFrame(patch);
          return;
        }

        const replacements = new Map([
          [
            'Ch\\u01b0a \\u0111\\u01b0\\u1ee3c c\\u1ea5p quy\\u1ec1n camera',
            'B\\u1ea1n kh\\u00f4ng c\\u00f3 quy\\u1ec1n truy c\\u1eadp'
          ],
          [
            'H\\u00e3y c\\u1ea5p quy\\u1ec1n camera cho tr\\u00ecnh duy\\u1ec7t ho\\u1eb7c WebView. Tr\\u00ean Flutter WebView c\\u1ea7n b\\u1eadt quy\\u1ec1n camera trong app.',
            'Vui l\\u00f2ng c\\u1ea5p quy\\u1ec1n cho camera.'
          ],
        ]);

        const fallbackTitle = 'B\\u1ea1n kh\\u00f4ng c\\u00f3 quy\\u1ec1n truy c\\u1eadp';
        const normalize = (value) => value.replace(/\\s+/g, ' ').trim();

        const replaceText = (targetRoot) => {
          if (!targetRoot) return;

          const walker = document.createTreeWalker(targetRoot, NodeFilter.SHOW_TEXT);
          const nodes = [];

          while (walker.nextNode()) {
            nodes.push(walker.currentNode);
          }

          for (const node of nodes) {
            const value = normalize(node.nodeValue);
            const lowerValue = value.toLowerCase();

            if (replacements.has(value)) {
              node.nodeValue = replacements.get(value);
            } else if (
              lowerValue.includes('camera') &&
              (
                value.includes('quy\\u1ec1n') ||
                lowerValue.includes('permission') ||
                lowerValue.includes('access')
              ) &&
              (
                value.includes('Ch\\u01b0a') ||
                value.includes('kh\\u00f4ng') ||
                lowerValue.includes('denied') ||
                lowerValue.includes('blocked')
              )
            ) {
              node.nodeValue = fallbackTitle;
            }
          }
        };

        replaceText(root);

        if (!window.__emposCameraPermissionTextObserver) {
          window.__emposCameraPermissionTextObserver = new MutationObserver(() => {
            replaceText(document.body || document.documentElement);
          });
          window.__emposCameraPermissionTextObserver.observe(root, {
            childList: true,
            subtree: true,
            characterData: true,
          });
        }

        window.__emposPatchCameraPermissionText = () => replaceText(document.body || document.documentElement);
      };

      patch();
    })();
  """;

  static const String _flutterBridgeScript = """
    (() => {
      window.__BOSS_EMPOS_FLUTTER__ = true;
      window.__IS_FLUTTER_WEBVIEW__ = true;
      window.isFlutter = true;
      window.isFlutterApp = true;
      window.isWebView = true;

      try {
        localStorage.setItem('flutter', '1');
        localStorage.setItem('isFlutter', '1');
        localStorage.setItem('webview', '1');
        localStorage.setItem('isWebView', '1');
        localStorage.setItem('platform', 'flutter');
      } catch (_) {}

      window.requestCameraPermissionFromFlutter = async () => {
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          return await window.flutter_inappwebview.callHandler('requestCameraPermission');
        }

        return true;
      };
    })();
  """;

  @override
  void initState() {
    super.initState();
    _prepareCameraPermissionFuture = _requestMediaPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _prepareCameraPermissionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(initialUrl),
            headers: {
              'X-Flutter-WebView': '1',
              'X-Boss-Empos-App': '1',
            },
          ),
          initialUserScripts: UnmodifiableListView<UserScript>([
            UserScript(
              source: _flutterBridgeScript,
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
            UserScript(
              source: _permissionTextPatch,
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
          ]),

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
            iframeAllow: "camera; microphone",
            iframeAllowFullscreen: true,
            applicationNameForUserAgent: 'BossEmposFlutterWebView',

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
            GetIt.instance.get<ConfigModel>().controller = webController;

            webController.addJavaScriptHandler(
              handlerName: 'requestCameraPermission',
              callback: (args) async {
                return _requestMediaPermissions();
              },
            );

            webController.addJavaScriptHandler(
              handlerName: 'requestCameraPermissionStatus',
              callback: (args) async {
                final granted = await _requestMediaPermissions();
                final cameraStatus = await Permission.camera.status;
                final microphoneStatus = await Permission.microphone.status;

                return {
                  'granted': granted,
                  'camera': cameraStatus.name,
                  'microphone': microphoneStatus.name,
                  'source': 'flutter',
                };
              },
            );
          },

          onPermissionRequest: (controller, request) async {
            debugPrint('WebView permission request: ${request.resources}');

            await _requestMediaPermissions();

            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },

          androidOnPermissionRequest: (controller, origin, resources) async {
            debugPrint('Android WebView permission request: $resources');

            await _requestMediaPermissions();

            return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT,
            );
          },

          onLoadStart: (webController, url) {
            unawaited(_patchPermissionText(webController));
          },

          onLoadStop: (webController, url) async {
            debugPrint("Loaded: $url");

            // Chỉ inject CSS nhẹ
            await webController.evaluateJavascript(
              source: """
                document.body.style.webkitTextSizeAdjust='100%';
                $_flutterBridgeScript
                $_permissionTextPatch
              """,
            );

            widget.voidCallback();
          },

          onUpdateVisitedHistory: (webController, url, isReload) {
            unawaited(_patchPermissionText(webController));
          },

          onConsoleMessage: (controller, msg) {
            debugPrint(msg.message);
          },

          onReceivedError: (controller, request, error) {
            debugPrint(error.description);
          },
        );
          },
        ),
      ),
    );
  }

  Future<bool> _requestMediaPermissions() async {
    final cameraGranted = await _requestPermission(Permission.camera);
    final microphoneGranted = await _requestPermission(Permission.microphone);

    return cameraGranted && microphoneGranted;
  }

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;
    debugPrint('$permission status before request: $status');

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
      return false;
    }

    status = await permission.request();
    debugPrint('$permission status after request: $status');
    return status.isGranted;
  }

  Future<void> _patchPermissionText(InAppWebViewController webController) async {
    try {
      await webController.evaluateJavascript(
        source: """
          $_flutterBridgeScript
          $_permissionTextPatch
        """,
      );
    } catch (error) {
      debugPrint('Patch permission text failed: $error');
    }
  }
}
