import 'package:flutter/material.dart';
import 'package:nonebot_webui_mobile/main.dart';
import 'package:nonebot_webui_mobile/utils/core.dart';
import 'package:nonebot_webui_mobile/utils/global.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Settings> {
  final hostController = TextEditingController();
  final portController = TextEditingController();
  final tokenController = TextEditingController();
  int _selectedProtocol = 0;

  @override
  void initState() {
    super.initState();
    hostController.text = Config.wsHost;
    portController.text = Config.wsPort.toString();
    tokenController.text = Config.token;
    _selectedProtocol = Config.useHttps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '连接设置',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (hostController.text.isNotEmpty &&
                          portController.text.isNotEmpty) {
                        final protocol = _selectedProtocol == 1
                            ? 'https'
                            : 'http';
                        try {
                          final res = await http
                              .get(
                                Uri.parse(
                                  "$protocol://${hostController.text}:${portController.text}/nbgui/v1/ping",
                                ),
                                headers: {
                                  "Authorization":
                                      "Bearer ${tokenController.text}",
                                },
                              )
                              .timeout(const Duration(seconds: 5));

                          if (res.statusCode == 200) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('host', hostController.text);
                            await prefs.setInt(
                              'port',
                              portController.text.isEmpty
                                  ? 2519
                                  : int.parse(portController.text),
                            );
                            await prefs.setString(
                              'token',
                              tokenController.text,
                            );
                            await prefs.setInt('https', _selectedProtocol);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('配置成功！')),
                            );
                            Config.wsHost = hostController.text;
                            Config.wsPort = int.parse(portController.text);
                            Config.token = tokenController.text;
                            Config.useHttps = _selectedProtocol;
                            broadcastStream = null;
                            socket.sink.close();
                            Data.isConnected = false;
                            connectToWebSocket(
                              Config.wsHost,
                              Config.wsPort,
                              Config.useHttps,
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
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请填写主机和端口')),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(' NoneBot Agent 主机'),
              const SizedBox(height: 8),
              Row(
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
                  Expanded(
                    child: TextField(
                      controller: hostController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '输入主机地址',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(' NoneBot Agent 端口'),
              const SizedBox(height: 8),
              TextField(
                controller: portController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '输入 NoneBot Agent 端口号',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(' NoneBot Agent Token'),
              const SizedBox(height: 8),
              TextField(
                controller: tokenController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '输入 NoneBot Agent Token',
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                '主题设置',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('颜色模式')),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                      child: DropdownButton<String>(
                        value: Config.theme['color'],
                        items: const [
                          DropdownMenuItem(value: 'light', child: Text('浅色模式')),
                          DropdownMenuItem(value: 'dark', child: Text('深色模式')),
                          DropdownMenuItem(
                            value: 'system',
                            child: Text('跟随系统'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              Provider.of<ThemeNotifier>(
                                context,
                                listen: false,
                              ).setThemeMode(value);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Text('Bot终端自动换行')),
                  Switch(
                    value: Config.autoWrap == 1,
                    trackColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (!states.contains(MaterialState.selected)) {
                        return Colors.grey.withOpacity(0.5);
                      }
                      return null;
                    }),
                    onChanged: (bool value) async {
                      final int intValue = value ? 1 : 0;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('autoWrap', intValue);
                      setState(() {
                        Config.autoWrap = intValue;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
