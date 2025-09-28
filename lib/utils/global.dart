// 全局变量
import 'package:web_socket_channel/web_socket_channel.dart';

late String version;
late WebSocketChannel socket;
Stream? broadcastStream;
String gOnOpen = '';
bool hasData = false;

/// 配置文件
class Config {
  /// ws 主机
  static String wsHost = '';

  /// ws 端口
  static int wsPort = 2519;

  /// token
  static String token = '';

  /// 启用https/wss
  static int useHttps = 0;

  /// 主题
  static Map theme = {"color": "system", "img": "default", "text": "default"};
}

/// 应用程序数据
class Data {
  static bool isConnected = false;

  ///Bot列表
  static List botList = [];

  ///CPU使用率
  static String cpuUsage = "NaN";

  ///RAM使用率
  static String ramUsage = "NaN";

  ///平台
  static String platform = "Unknown";

  ///Bot信息
  static Map botInfo = {
    "name": "Unknown",
    "path": "Unknown",
    "time": "Unknown",
    "isRunning": false,
    "pid": Null,
  };

  ///Bot日志
  static String botLog = '';

  ///版本信息
  static Map agentVersion = {
    "version": "Unknown",
    "nbcli": "Unknown",
    "python": "Unknown",
  };

  /// 安装Bot时的日志
  static List installBotLog = [];
}

// 神秘开关
bool debug = false;
