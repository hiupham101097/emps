import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'home_page.dart';
import 'models/config_model.dart';

GetIt getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  var config = ConfigModel();

  getIt.registerSingleton<ConfigModel>(config);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boss Empos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          primary: const Color(0xFF128F7D),
          inversePrimary: const Color(0xFF128F7D),
          seedColor: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFF128F7D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF128F7D),
          titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'EMPOS'),
    );
  }
}
