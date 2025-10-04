import 'dart:async';
import 'package:nonebot_webui_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nonebot_webui_mobile/ui/main_pages/settings.dart';
import 'package:nonebot_webui_mobile/ui_mobile/main_pages/about.dart';
import 'package:nonebot_webui_mobile/ui/main_pages/import_bot.dart';
import 'package:nonebot_webui_mobile/ui_mobile/main_pages/manage_bot.dart';
import 'package:nonebot_webui_mobile/ui/main_pages/createbot.dart';
import 'package:nonebot_webui_mobile/utils/core.dart';
import 'package:nonebot_webui_mobile/utils/global.dart';
import 'package:provider/provider.dart';

class MainPageMobile extends StatefulWidget {
  const MainPageMobile({super.key});

  @override
  State<MainPageMobile> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainPageMobile> {
  final myController = TextEditingController();
  int _selectedIndex = 0;
  Timer? timer;
  Timer? timer2;
  int runningCount = 0;
  String title = '主页';

  @override
  void initState() {
    super.initState();
    connectToWebSocket(Config.wsHost, Config.wsPort, Config.useHttps);
    setState(() {
      getSystemStatus();
      getBotLog();
    });
  }

  //每过1.5秒获取一次
  getSystemStatus() async {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      socket.sink.add('ping?token=${Config.token}');
      socket.sink.add('system?token=${Config.token}');
      socket.sink.add('platform?token=${Config.token}');
      socket.sink.add('botList?token=${Config.token}');
      runningCount = Data.botList
          .where((bot) => bot['isRunning'] == true)
          .length;
      // 拿到状态后刷新页面
      setState(() {});
    });
  }

  getBotLog() async {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer2) async {
      if (gOnOpen.isNotEmpty) {
        socket.sink.add("bot/log/$gOnOpen?token=${Config.token}");
        socket.sink.add("botInfo/$gOnOpen?token=${Config.token}");
        socket.sink.add("bot/stderr/$gOnOpen?token=${Config.token}");
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    timer2?.cancel();
    super.dispose();
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required int index,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: index == _selectedIndex
            ? Config.theme['color'] == 'light' ||
                      Config.theme['color'] == 'default'
                  ? const Color.fromRGBO(234, 82, 82, 1)
                  : const Color.fromRGBO(147, 112, 219, 1)
            : Config.theme['color'] == 'light' ||
                  Config.theme['color'] == 'default'
            ? Colors.grey[600]
            : Colors.white,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: index == _selectedIndex
              ? Config.theme['color'] == 'light' ||
                        Config.theme['color'] == 'default'
                    ? const Color.fromRGBO(234, 82, 82, 1)
                    : const Color.fromRGBO(147, 112, 219, 1)
              : Config.theme['color'] == 'light' ||
                    Config.theme['color'] == 'default'
              ? Colors.grey[600]
              : Colors.white,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeNotifier>(context);
    dynamic size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NoneBot WebUI Mobile',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  Image.asset('lib/assets/logo.png', width: 100, height: 100),
                  const Text(
                    'NoneBot WebUI',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(icon: Icons.home_rounded, text: '主页', index: 0),
            _buildDrawerItem(
              icon: Icons.dashboard_rounded,
              text: 'Bot控制台',
              index: 1,
            ),
            _buildDrawerItem(icon: Icons.add_rounded, text: '创建', index: 2),
            _buildDrawerItem(
              icon: Icons.download_rounded,
              text: '导入',
              index: 3,
            ),
            _buildDrawerItem(
              icon: Icons.settings_rounded,
              text: '设置',
              index: 4,
            ),
            _buildDrawerItem(
              icon: Icons.balance_rounded,
              text: '开源许可证',
              index: 5,
            ),
            _buildDrawerItem(icon: Icons.info_rounded, text: '关于', index: 6),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Center(
                                                    child: SvgPicture.asset(
                                                      'lib/assets/icons/CPU.svg',
                                                      width: width * 2 / 21,
                                                      height: width * 2 / 21,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      'CPU',
                                                      style: TextStyle(
                                                        fontSize: height * 0.02,
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      Data.cpuUsage,
                                                      style: TextStyle(
                                                        fontSize: height * 0.03,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Center(
                                                    child: SvgPicture.asset(
                                                      'lib/assets/icons/RAM.svg',
                                                      width: width * 2 / 21,
                                                      height: width * 2 / 21,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      'RAM',
                                                      style: TextStyle(
                                                        fontSize: height * 0.02,
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      Data.ramUsage,
                                                      style: TextStyle(
                                                        fontSize: height * 0.03,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Center(
                                                    child: SvgPicture.asset(
                                                      'lib/assets/icons/bot.svg',
                                                      width: width * 2 / 21,
                                                      height: width * 2 / 21,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      '运行中',
                                                      style: TextStyle(
                                                        fontSize: height * 0.02,
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      '$runningCount/${Data.botList.length}',
                                                      style: TextStyle(
                                                        fontSize: height * 0.03,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(4),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.computer,
                                                          size: height * 0.050,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          Data.platform,
                                                          style: TextStyle(
                                                            fontSize:
                                                                height * 0.025,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(4),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons
                                                              .electrical_services_outlined,
                                                          size: height * 0.055,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Data.isConnected
                                                            ? Text(
                                                                '已连接',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize:
                                                                      height *
                                                                      0.025,
                                                                ),
                                                              )
                                                            : Text(
                                                                '未连接',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize:
                                                                      height *
                                                                      0.025,
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const Divider(
                          //   height: 20,
                          //   thickness: 2,
                          //   indent: 20,
                          //   endIndent: 20,
                          //   color: Colors.grey,
                          // ),
                          SizedBox(height: height * 0.02),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Bot列表',
                                    style: TextStyle(
                                      fontSize: height * 0.03,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '名称',
                                        style: TextStyle(
                                          fontSize: height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          textBaseline: TextBaseline.alphabetic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '状态',
                                        style: TextStyle(
                                          fontSize: height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          textBaseline: TextBaseline.alphabetic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '操作',
                                        style: TextStyle(
                                          fontSize: height * 0.02,
                                          fontWeight: FontWeight.bold,
                                          textBaseline: TextBaseline.alphabetic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 20,
                                  thickness: 2,
                                  indent: 20,
                                  endIndent: 20,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: Data.botList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          socket.sink.add(
                                            "botInfo/${Data.botList[index]['id']}?token=${Config.token}",
                                          );
                                          gOnOpen = Data.botList[index]['id'];
                                          setState(() {
                                            _selectedIndex = 1;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                Data.botList[index]['name'],
                                                style: TextStyle(
                                                  fontSize: height * 0.02,
                                                  fontWeight: FontWeight.bold,
                                                  textBaseline:
                                                      TextBaseline.alphabetic,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              child:
                                                  Data.botList[index]['isRunning']
                                                  ? Text(
                                                      '运行中',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: height * 0.02,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  : Text(
                                                      '未运行',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: height * 0.02,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                            ),
                                            Expanded(
                                              child:
                                                  Data.botList[index]['isRunning']
                                                  ? Center(
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.stop_rounded,
                                                        ),
                                                        tooltip: '停止',
                                                        onPressed: () {
                                                          socket.sink.add(
                                                            'bot/stop/${Data.botList[index]['id']}?token=${Config.token}',
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Center(
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .play_arrow_rounded,
                                                        ),
                                                        tooltip: '启动',
                                                        onPressed: () {
                                                          socket.sink.add(
                                                            'bot/run/${Data.botList[index]['id']}?token=${Config.token}',
                                                          );
                                                        },
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        height: 20,
                                        thickness: 2,
                                        indent: 20,
                                        endIndent: 20,
                                        color: Colors.grey[300],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    gOnOpen.isNotEmpty
                        ? const ManageBot()
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('lib/assets/loading.gif'),
                                const SizedBox(height: 10),
                                const Text('你还没有选择要打开的bot'),
                              ],
                            ),
                          ),
                    const CreateBot(),
                    importBot(),
                    const Settings(),
                    LicensePage(
                      applicationName: 'NoneBot WebUI',
                      applicationVersion: version,
                      applicationIcon: const Image(
                        image: AssetImage('lib/assets/logo.png'),
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const About(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
