import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:nonebot_webui_mobile/utils/global.dart';
import 'package:nonebot_webui_mobile/utils/ws_handler.dart';

Timer? timer;

void connectToWebSocket(host, port, int ws) {
  late Uri wsUrl;
  //连接到WebSocket
  if (debug) {
    if (ws == 1) {
      wsUrl = Uri.parse('wss://$host:$port/nbgui/v1/ws');
    } else {
      wsUrl = Uri.parse('ws://$host:$port/nbgui/v1/ws');
    }
  } else {
    if (ws == 1) {
      wsUrl = Uri.parse('wss://$host:$port/nbgui/v1/ws');
    } else {
      wsUrl = Uri.parse('ws://$host:$port/nbgui/v1/ws');
    }
  }
  socket = WebSocketChannel.connect(wsUrl);
  broadcastStream = socket.stream.asBroadcastStream();
  broadcastStream!.listen((event) {
    wsHandler(event);
  }, onDone: () {
    Data.isConnected = false;
    reconnect();
  }, onError: (error) {
    Data.isConnected = false;
    reconnect();
  }, cancelOnError: false);
}

void reconnect() {
  //循环重连
  if (timer != null && timer!.isActive) return;
  timer = Timer.periodic(const Duration(milliseconds: 1500), (t) {
    if (Data.isConnected) {
      t.cancel();
    } else {
      socket.sink.close();
      connectToWebSocket(Config.wsHost, Config.wsPort, Config.useHttps);
    }
  });
}
