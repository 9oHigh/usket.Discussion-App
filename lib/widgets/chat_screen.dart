import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.appBartitle});

  final String appBartitle;

  // 생성자에서 userID와 roomID를 받아서 처리
  // final String userID;
  // final String roomID;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  IO.Socket? socket;
  List<Map<String, String>> messages = [];
  String roomId = "test_room"; // 방 ID 예시

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _connectSocket();
  }

  void _connectSocket() {
    // 소켓 초기화 및 서버에 연결
    socket = IO.io('http://localhost:3001/chat', <String, dynamic> {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    // 연결 확인
    socket!.on('connect', (_) {
      print('Connected to server');
      socket!.emit('join', {'roomId': roomId, 'playerId': 'Guest1234'}); // 방에 참가
    });

    // 메시지 수신
    socket!.on('msg', (data) {
      setState(() {
        Map<String, String> message = {};
        data.forEach((key, value) {
          message[key] = value;
        });

        messages.add(message);
        _textEditingController.clear();
      });
    });

    // 연결 해제 확인
    socket!.on('disconnect', (_) => print('Disconnected'));
  }

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) {
      return;
    }

    final String message = _textEditingController.text;
    socket!.emit('msg', {'roomId': roomId, 'msg': message, 'playerId': 'Guest1234'});

    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.black,
                  ))
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
              children: [
                  Expanded(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                                final message = messages[index];
                                bool isMe = message['playerId'] == "Guest1234";
                                // bool isMe = message['isMe'] == "true";
                                return _buildMessage(
                                    message["playerId"], message["msg"], isMe);
                                // return _buildMessage(
                                //     message["username"], message["message"], isMe);
                            },
                        ),
                      )
                  ),
                _buildMessageInput()
              ],
          ),
        )
    );
  }

  Widget _buildMessage(String? username, String? message, bool isMe) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          Text(
            username ?? "",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.blueGrey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message ?? "",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
                height: 44,
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                      hintText: "메세지를 입력하세요",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Colors.grey.shade300,
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.grey, // 기본 테두리 색상
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.blue, // 포커스 시 테두리 색상
                        ),
                      ),
                  ),
                ),
              )
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            height: 44,
            child: ElevatedButton(
                onPressed: _sendMessage,
                child: Text("전송")
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket?.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

}
