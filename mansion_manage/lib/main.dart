import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String _token_key = '';
String _uid = '';
String _password = '';

void main() {
  runApp(MaterialApp(
    title: 'My App',
    theme: ThemeData(brightness: Brightness.dark),
    home: LoginPage(),
  ));
}

// ログイン成功
void LoginSuccess() {
  runApp(MaterialApp(
    title: 'My App',
    theme: ThemeData(brightness: Brightness.dark),
    home: MainApp(),
  ));
}

// ログインページ
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true; // パスワード表示フラグ
  final _idController = TextEditingController();        // ユーザーID
  final _passwordController = TextEditingController();  // パスワード
  // エラーメッセージ
  final loginErrorMsg = SnackBar(
    content: const Text('ログインに失敗しました。'),
  );

  @override
  void initState() {
    loadInfo();
    super.initState();
  }

  Future loadInfo() async {
    var prefs = await SharedPreferences.getInstance();
    List<String>? loginInfo = prefs.getStringList('loginInfo');
    var uid = loginInfo![0];
    var password = loginInfo![1];
    if (uid != "" && password != "") {
      _idController.text = uid;
      _passwordController.text = password;
      // login(uid, password);
    }
  }

  // ログイン処理
  Future<String> login(String uid, String p_password) async {
    final response = await http.post(
      Uri.parse('https://tantan.itigo.jp/men/public/tower/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'uid': uid,
        'password': p_password
      }),
    );

    if (response.statusCode == 200) {
      if (response.body != '-1') {
        // ログイン情報保存
        var prefs = await SharedPreferences.getInstance();
        var loginInfo = [_idController.text, _passwordController.text];
        prefs.setStringList('loginInfo', loginInfo);
        _token_key = response.body;
        _uid = _idController.text;
        _password = _passwordController.text;
        LoginSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(loginErrorMsg);
      }
      return response.body;
    } else {
      print("api failed");
      print(response.statusCode);
      throw Exception('Failed to login.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/bg.jpg'),
              fit: BoxFit.cover,
          )
        ),
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(80),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'ユーザーID',
                    fillColor: Colors.black54,
                    filled: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                      labelText: 'パスワード',
                      suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          }),
                    fillColor: Colors.black54,
                    filled: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: (){
                      login(_idController.text, _passwordController.text);
                    },
                    child: Text('ログイン')
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// WebViewアプリの状態を持つStatefulWidget
class MainApp extends StatefulWidget {
  /// WebViewAppのコンストラクタ
  const MainApp({super.key});

  /// 状態オブジェクトを作成
  @override
  State<MainApp> createState() => _WebViewAppState();
}

/// WebViewAppの状態を管理するStateクラス
class _WebViewAppState extends State<MainApp> {
  /// WebViewControllerオブジェクト
  late final WebViewController controller;

  /// 初期状態を設定
  @override
  void initState() {
    super.initState();
    var url = 'https://tantan.itigo.jp/men/public/tower?uid=$_uid&key=$_token_key';
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(url),
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