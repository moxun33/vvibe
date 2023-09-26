//hack.chat 连接
import 'dart:convert';
import 'package:vvibe/utils/logger.dart';
import 'package:web_socket_channel/io.dart';

class Hackchat {
  Hackchat(
      {required this.nickname,
      this.onChat,
      this.msgData,
      this.onClose,
      this.onError});
  final String nickname;
  final String room = 'vvibe-community';
  Function? msgData;
  Function? onChat;
  Function? onClose;
  Function? onError;

  IOWebSocketChannel? _ws;

  String? _sessionId;
  //初始化
  init() {
    Logger.info('开始连接hackchat');
    _ws = IOWebSocketChannel.connect('wss://hack.chat/chat-ws',
        connectTimeout: const Duration(seconds: 30),
        headers: {
          'Origin': 'https://hack.chat',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36'
        });
    Logger.info('连接hackchat成功');
    startSession();
    _setListener();
  }

  sendMsg(String text) {
    send({"cmd": "chat", "channel": room, "text": text});
  }

  startSession() {
    send({"cmd": "session", "isBot": false});
  }

  resumeSession() {
    if (_sessionId == null) return;

    send({"cmd": "session", "isBot": false, 'id': _sessionId});
  }

  send(Map<String, dynamic> data) {
    try {
      if (_ws == null) return;

      _ws!.sink.add(jsonEncode(data));
    } catch (e) {
      Logger.error('hackchat sending error:' + e.toString());
    }
  }

  get readyState => _ws?.innerWebSocket?.readyState;

  close() {
    if (_ws == null) return;
    _sessionId = null;
    disconnectUser();
    _ws!.sink.close();
  }

  disconnectUser() {
    send({'cmd': 'disconnect'});
  }

  _setListener() {
    if (_ws == null) return;

    _ws!.stream.listen(
      _onReceive,
      onDone: () {
        Logger.warn('hackchat连接关闭');
        close();

        if (onClose != null) {
          onClose!();
        }
      },
      onError: (error) {
        Logger.error('hackchat发生错误 $error');
        if (onError != null) {
          onError!();
        }
      },
      cancelOnError: true,
    );
  }

  void _onReceive(msg) {
    final Map<String, dynamic> obj = jsonDecode(msg);
    switch (obj['cmd']) {
      case 'session':
        _onSessionReceive(obj);
        break;
      case 'chat':
        _onChatReceive(obj);

        break;
      case 'warn':
        _onWarn(obj);
        break;
      case 'onlineRemove':
        _onWarn(obj);
        break;
      case 'onlineAdd':
        _onWarn(obj);
        break;
      case 'onlineSet':
        _onWarn(obj);
        break;
      default:
    }
    if (msgData != null) {
      msgData!(obj);
    }
    //Logger.info("收到hackchat数据:" + msg);
  }

  _onChatReceive(Map<String, dynamic> data) {
    if (onChat != null) {
      onChat!(data);
    }
  }

  _onSessionReceive(Map<String, dynamic> data) {
    _joinRoom();
    if (data['sessionID'] != null) {
      resumeSession();
    }
  }

  _onOnlineRemove(Map<String, dynamic> data) {}
  _onOnlineAdd(Map<String, dynamic> data) {}
  _onOnlineSet(Map<String, dynamic> data) {}

//加入频道
  void _joinRoom() {
    send({"cmd": "join", "nick": nickname, "pass": "", "channel": room});
  }

  _onWarn(Map<String, dynamic> data) {
    final text = data['text'];
    if (text == null) return;
    Logger.warn('hackchat $text');
  }
}
