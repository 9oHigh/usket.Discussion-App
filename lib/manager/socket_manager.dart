import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  late SharedPreferences prefs;
  late int playerId;

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal() {
    _initPrefs();
  }
  // Emulator - 10.0.2.2:3001
  // Device - ipconfig에서 ip 주소 넣어서 사용 ex) http://127.168.0.23:3001
  final String _serverUrl = 'http://192.168.0.23:3001/chat';
  IO.Socket? _socket;
  Map<String, List<Map<String, String>>> chats = {};
  final Map<String, StreamController<List<Map<String, String>>>>
      _chatStreamControllers = {};
  final Map<String, StreamController<bool>> _exitControllers = {};

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    playerId = prefs.getInt('playerId') ?? 0;
    await _loadChatHistoryFromPrefs();
  }

  Future<void> _loadChatHistoryFromPrefs() async {
    List<String> keys = prefs.getStringList('chatRoomIds') ?? [];
    for (var roomId in keys) {
      String? chatData = prefs.getString(roomId);
      if (chatData != null) {
        List<Map<String, String>> chatList = List<Map<String, String>>.from(
            jsonDecode(chatData).map((e) => Map<String, String>.from(e)));
        chats[roomId] = chatList;
        _getStreamController(roomId).add(chatList);
        _getExitStreamController(roomId).add(false);
      }
    }
  }

  Future<void> _saveChatHistoryToPrefs(String roomId) async {
    if (chats.containsKey(roomId)) {
      String chatData = jsonEncode(chats[roomId]);
      await prefs.setString(roomId, chatData);
    }
  }

  Future<void> deleteRoomChat(String roomId) async {
    chats.remove(roomId);
    await prefs.remove(roomId);
    await _chatStreamControllers[roomId]?.close();
    _getExitStreamController(roomId).add(true);
  }

  initSocket() async {
    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .build(),
    );

    await _addListener();

    _socket?.connect();
  }

  Future<void> _addListener() async {
    _socket?.onConnect((_) {
      print("Connected to $_serverUrl");
    });

    _socket?.onDisconnect((_) {
      print("Disconnected from $_serverUrl");
    });

    _socket?.on('join', (data) {
      List<String> chatRoomIds = prefs.getStringList('chatRoomIds') ?? [];
      String id = data['roomId'].toString();
      if (!chatRoomIds.contains(id)) {
        chatRoomIds.add(id);
        prefs.setStringList('chatRoomIds', chatRoomIds);
        _getStreamController(id).add([]);
      } else {
        if (chats[id] != null) {
          _getStreamController(id).add(chats[id]!);
        }
      }
    });

    _socket?.on('exit', (data) {
      List<String> chatRoomIds = prefs.getStringList('chatRoomIds') ?? [];
      String id = data['roomId'].toString();
      if (chatRoomIds.contains(id)) {
        chatRoomIds.remove(id);
        prefs.setStringList('chatRoomIds', chatRoomIds);
        deleteRoomChat(id);
        _getExitStreamController(id).add(true);
      }
    });

    _socket?.on('getUserList', (_) {});

    _socket?.on('msg', (data) {
      String roomId = data['roomId'];
      String message = data['msg'];
      String senderId = data['playerId'];
      handleRoomMessage(roomId, senderId, message);
    });
  }

  Stream<bool> getExitStream(String roomId) {
    return _getExitStreamController(roomId).stream;
  }

  StreamController<bool> _getExitStreamController(String roomId) {
    if (!_exitControllers.containsKey(roomId)) {
      _exitControllers[roomId] = StreamController<bool>.broadcast();
    }
    return _exitControllers[roomId]!;
  }

  Stream<List<Map<String, String>>> getChatStream(String roomId) {
    return _getStreamController(roomId).stream;
  }

  StreamController<List<Map<String, String>>> _getStreamController(
      String roomId) {
    if (!_chatStreamControllers.containsKey(roomId)) {
      _chatStreamControllers[roomId] =
          StreamController<List<Map<String, String>>>.broadcast();
    }
    return _chatStreamControllers[roomId]!;
  }

  joinRoom(int roomId) {
    _socket?.emit(
        'join', {'roomId': roomId.toString(), 'playerId': playerId.toString()});
  }

  sendMessage(int roomId, String message) {
    _socket?.emit('msg', {
      'roomId': roomId.toString(),
      'msg': message,
      'playerId': playerId.toString()
    });
  }

  exitRoom(String roomId) {
    _socket?.emit('exit', {
      'roomId': roomId,
    });
  }

  handleRoomMessage(String roomId, String senderId, String message) {
    if (!chats.containsKey(roomId)) {
      chats[roomId] = [];
    }

    chats[roomId]!.add({'senderId': senderId, 'text': message});
    _getStreamController(roomId).add(chats[roomId]!);

    _saveChatHistoryToPrefs(roomId);
  }
}
