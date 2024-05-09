import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// エントリポイント
void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: const WebViewApp(),
    ),
  );
}

/// WebViewアプリの状態を持つStatefulWidget
class WebViewApp extends StatefulWidget {
  /// WebViewAppのコンストラクタ
  const WebViewApp({super.key});

  /// 状態オブジェクトを作成
  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

/// WebViewAppの状態を管理するStateクラス
class _WebViewAppState extends State<WebViewApp> {
  /// WebViewControllerオブジェクト
  late final WebViewController controller;

  /// 初期状態を設定
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://tantan.itigo.jp/men/public/tower/'),
      );
  }

  /// アプリのUIを構築
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}