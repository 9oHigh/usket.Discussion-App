import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.appBartitle});

  final String appBartitle;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> messages = [
    {"username": "게스트#8120", "message": "hi", "isMe": "false"},
    {"username": "게스트#8120", "message": "hello", "isMe": "false"},
    {"username": "게스트#5800", "message": "안녕", "isMe": "true"},
    {"username": "게스트#5800", "message": "반가워", "isMe": "true"},
  ];

  final TextEditingController _textEditingController = TextEditingController();

  void _sendMessage() {
    if (_textEditingController.text.isEmpty) {
      return;
    }

    setState(() {
      final Map<String, String> newMessage = {
        "username": "게스트#5800",
        "message": _textEditingController.text,
        "isMe": "true"
      };
      messages.add(newMessage);
      _textEditingController.clear();
    });
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
        body: Column(
            children: [
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                              final message = messages[index];
                              bool isMe = message['isMe'] == "true";
                              return _buildMessage(
                                  message["username"], message["message"], isMe);
                          },
                      ),
                    )
                ),
              _buildMessageInput()
            ],
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
}
