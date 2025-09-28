import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nonebot_webui_mobile/ui/main_page.dart';
import 'package:nonebot_webui_mobile/ui_mobile/main_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nonebot_webui_mobile/utils/global.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  version = '0.1.0';
  debug = true;

  // 默认主题模式为 'system'
  String initialThemeMode = 'system';
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? getHost = prefs.getString('host');
  final int? getPort = prefs.getInt('port');
  final String? getToken = prefs.getString('token');
  final String? getTheme = prefs.getString('theme');
  final int? getHttps = prefs.getInt('https');

  if (getTheme != null) {
    Config.theme = jsonDecode(getTheme);
    initialThemeMode = Config.theme['color'] ?? 'system';
  } else {
    Config.theme['color'] = 'system';
  }

  if (getHost != null &&
      getPort != null &&
      getToken != null &&
      getHttps != null) {
    Config.wsHost = getHost;
    Config.wsPort = getPort;
    Config.token = getToken;
    Config.useHttps = getHttps;
    hasData = true;
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          ThemeNotifier(_getThemeModeFromString(initialThemeMode)),
      child: const MyApp(),
    ),
  );
}

// 将字符串转换为 ThemeMode 枚举
ThemeMode _getThemeModeFromString(String themeMode) {
  switch (themeMode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.system;
  }
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  ThemeMode get themeMode => _themeMode;
  void setThemeMode(String mode) {
    _themeMode = _getThemeModeFromString(mode);
    Config.theme['color'] = mode;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('theme', jsonEncode(Config.theme));
    });
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      theme: _getTheme('light'),
      darkTheme: _getTheme('dark'),
      themeMode: themeNotifier.themeMode,
      home: hasData
          ? Builder(
              builder: (context) {
                return (MediaQuery.of(context).size.width >
                        MediaQuery.of(context).size.height)
                    ? const MainPage()
                    : const MainPageMobile();
              },
            )
          : const LoginPage(),
    );
  }
}

///颜色主题
ThemeData _getTheme(mode) {
  switch (mode) {
    case 'light' || 'default':
      return ThemeData.light().copyWith(
        canvasColor: const Color.fromRGBO(254, 239, 239, 1),
        primaryColor: const Color.fromRGBO(234, 82, 82, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(234, 82, 82, 1),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.selected)) {
              return const Color.fromRGBO(234, 82, 82, 1);
            }
            return Colors.white;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(234, 82, 82, 1),
        ),
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(234, 82, 82, 1)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(234, 82, 82, 1),
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(234, 82, 82, 1)),
        ),
      );
    case 'dark':
      return ThemeData.dark().copyWith(
        canvasColor: const Color.fromRGBO(18, 18, 18, 1),
        primaryColor: const Color.fromRGBO(147, 112, 219, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(147, 112, 219, 1),
        ),
        checkboxTheme: const CheckboxThemeData(
          checkColor: MaterialStatePropertyAll(
            Color.fromRGBO(147, 112, 219, 1),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(147, 112, 219, 1),
        ),
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(147, 112, 219, 1)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(147, 112, 219, 1),
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(
            Color.fromRGBO(147, 112, 219, 1),
          ),
        ),
      );
    default:
      return ThemeData.light().copyWith(
        canvasColor: const Color.fromRGBO(254, 239, 239, 1),
        primaryColor: const Color.fromRGBO(234, 82, 82, 1),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(234, 82, 82, 1),
        ),
        checkboxTheme: const CheckboxThemeData(
          checkColor: MaterialStatePropertyAll(Color.fromRGBO(234, 82, 82, 1)),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(234, 82, 82, 1),
        ),
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(234, 82, 82, 1)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(234, 82, 82, 1),
        ),
        switchTheme: const SwitchThemeData(
          trackColor: MaterialStatePropertyAll(Color.fromRGBO(234, 82, 82, 1)),
        ),
      );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final myController = TextEditingController();
  final portController = TextEditingController();
  final tokenController = TextEditingController();
  int _selectedProtocol = 0; // 0 for ws, 1 for wss
  String fileContent = '';
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  Future<void> _register() async {
    final String license = await rootBundle.loadString('lib/assets/LICENSE');
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(['NoneBot WebUI Mobile'], license);
    });
  }

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void dispose() {
    myController.dispose();
    portController.dispose();
    tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕的尺寸
    dynamic screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    double inputFieldWidth = (screenHeight > screenWidth)
        ? screenWidth * 0.75
        : screenHeight * 0.5;
    double buttonWidth = (screenHeight > screenWidth)
        ? screenWidth * 0.09
        : screenHeight * 0.07;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenHeight * 0.2),
                Text(
                  '欢迎使用 NoneBot WebUI Mobile',
                  style: TextStyle(
                    fontSize: screenHeight > screenWidth
                        ? screenWidth * 0.05
                        : screenHeight * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "你似乎是第一次打开，请先进行配置",
                  style: TextStyle(
                    fontSize: screenHeight > screenWidth
                        ? screenWidth * 0.035
                        : screenHeight * 0.035,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  width: inputFieldWidth,
                  height: inputFieldWidth * 0.175,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.38),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedProtocol,
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('ws://')),
                              DropdownMenuItem(value: 1, child: Text('wss://')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedProtocol = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 主机地址输入框
                      Expanded(
                        child: TextField(
                          controller: myController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '主机地址',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: inputFieldWidth,
                  height: inputFieldWidth * 0.175,
                  child: TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'NoneBot Agent 端口',
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: inputFieldWidth,
                  height: inputFieldWidth * 0.175,
                  child: TextField(
                    controller: tokenController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'NoneBot Agent Token',
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () async {
                      final host = myController.text;
                      final port = int.tryParse(portController.text);
                      final token = tokenController.text;

                      if (host.isEmpty || port == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入有效的主机和端口')),
                        );
                        return;
                      }

                      try {
                        // 根据选择的协议构建URL
                        final protocol = _selectedProtocol == 1
                            ? 'https'
                            : 'http';
                        final res = await http
                            .get(
                              Uri.parse(
                                "$protocol://$host:$port/nbgui/v1/ping",
                              ),
                              headers: {"Authorization": "Bearer $token"},
                            )
                            .timeout(const Duration(seconds: 5));

                        if (res.statusCode == 200) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('host', host);
                          await prefs.setInt('port', port);
                          await prefs.setString('token', token);
                          // 保存协议选择
                          await prefs.setInt('https', _selectedProtocol);

                          Config.wsHost = host;
                          Config.wsPort = port;
                          Config.token = token;
                          // 更新全局配置
                          Config.useHttps = _selectedProtocol;
                          hasData = true;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('配置成功！')),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  (MediaQuery.of(context).size.width >
                                      MediaQuery.of(context).size.height)
                                  ? const MainPage()
                                  : const MainPageMobile(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '连接失败: ${res.statusCode} ${res.body}',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('连接异常: $e')));
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                      shape: MaterialStateProperty.all(const StadiumBorder()),
                      iconSize: MaterialStateProperty.all(24),
                      minimumSize: MaterialStateProperty.all(
                        Size(buttonWidth * 4, buttonWidth),
                      ),
                    ),
                    child: Text(
                      '保存并连接',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: buttonWidth * 0.3,
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container()),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      'Powered by Flutter',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      'Released under the GPL-3 License',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
