import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nonebot_webui_mobile/assets/my_flutter_app_icons.dart';
import 'package:nonebot_webui_mobile/utils/global.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _MoreState();
}

class _MoreState extends State<About> {
  int tapCount = 0;
  final int tapsToReveal = 5;

  void _handleTap() {
    setState(() {
      tapCount++;
      if (tapCount >= tapsToReveal) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: <Widget>[
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset('lib/assets/loading.gif'),
                  ),
                  const SizedBox(width: 8),
                  const Text('UWU'),
                ],
              ),
              content: Image.asset('lib/assets/colorEgg.png'),
              actions: <Widget>[
                TextButton(
                  child: const Text('关闭'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        _resetCounter();
      }
    });
  }

  void _resetCounter() {
    setState(() {
      tapCount = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    socket.sink.add('version?token=${Config.token}');
    Future.delayed(const Duration(milliseconds: 850), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Center(
              child: Image.asset(
                'lib/assets/logo.png',
                width: MediaQuery.of(context).size.height * 0.2,
                height: null,
                fit: BoxFit.contain,
              ),
            ),
            const Center(
              child: Text(
                "NoneBot WebUI Mobile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Center(
              child: Text(
                "_✨新一代NoneBot图形化界面✨_",
                style: TextStyle(fontFamily: 'JetBrainsMono'),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 2,
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text(
                '软件版本',
                textScaler: TextScaler.linear(1.05),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: InkWell(onTap: _handleTap, child: Text(version)),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text(
                'Agent 版本',
                textScaler: TextScaler.linear(1.05),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(Data.agentVersion['version']),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text(
                'Python 版本',
                textScaler: TextScaler.linear(1.05),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(Data.agentVersion['python']),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text(
                'nb-cli 版本',
                textScaler: TextScaler.linear(1.05),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(Data.agentVersion['nbcli']),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text:
                            'https://github.com/nonebot_webui_mobile/nonebot-flutter-gui',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('项目仓库链接已复制到剪贴板'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(MyFlutterApp.github),
                  tooltip: '项目仓库地址',
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'https://doc.nbgui.top'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已复制到剪贴板'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book_rounded),
                  tooltip: '文档地址',
                  iconSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
