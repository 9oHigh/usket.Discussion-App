import 'package:flutter/material.dart';
import 'package:app_team1/manager/socket_manager.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';
import '../app_bar.dart';
import '../utils/constants.dart';
import '../styles/ui_styles.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final DateTime endTime;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.endTime,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketManager socketManager = SocketManager();
  final TextEditingController chatController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (DateTime.now().isAfter(widget.endTime)) {
          _showEndTimeAlert();
          _timer?.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    chatController.dispose();
    super.dispose();
  }

  _showEndTimeAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text("채팅 종료")),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 40),
            child: const Center(child: Text("채팅이 종료되었습니다🥲")),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  context.pop();
                  context.pop(true);
                },
                child: const Text("확인"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.appBarContentsColor,
            ),
            onPressed: () => context.pop(),
          ),
          title: widget.roomName,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, String>>>(
                stream: socketManager.getChatStream(widget.roomId),
                initialData: socketManager.chats[widget.roomId],
                builder: (context, snapshot) {
                  var reversedMessages = snapshot.data?.reversed.toList() ?? [];
                  if (reversedMessages.isEmpty) {
                    return const Center(
                      child: Text("아직 채팅이 없어요.\n먼저 대화를 시작해보세요 :)"),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: reversedMessages.length,
                    itemBuilder: (context, index) {
                      final message = reversedMessages[index];
                      final senderId = message['senderId'];
                      final text = message['text'] ?? "";
                      final isMe =
                          senderId == socketManager.playerId.toString();
                      final isFirstMessageFromSender =
                          index == reversedMessages.length - 1 ||
                              (index < reversedMessages.length - 1 &&
                                  reversedMessages[index + 1]['senderId'] !=
                                      senderId);
                      return Column(
                        children: [
                          if (!isMe && isFirstMessageFromSender)
                            Padding(
                              padding: const EdgeInsets.only(left: 65),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Player $senderId님',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe && isFirstMessageFromSender) ...{
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[400],
                                    child: const Icon(
                                      Icons.person,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              } else ...{
                                const Padding(
                                    padding: EdgeInsets.only(left: 55)),
                              },
                              Expanded(
                                child: Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? AppColors.primaryColor
                                          : Colors.white,
                                      borderRadius: isMe
                                          ? const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                              bottomLeft: Radius.circular(15),
                                              bottomRight:
                                                  Radius.zero,
                                            )
                                          : const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                              bottomLeft: Radius.zero,
                                              bottomRight: Radius.circular(
                                                  15),
                                            ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          text,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Stack(
                children: [
                  Container(
                    decoration: createShadowStyle(
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                        borderRadius: 25),
                    child: TextField(
                      controller: chatController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: '보내실 메세지를 입력하세요.',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1, 
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.fromLTRB(15, 10, 60, 10),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -4,
                    child: IconButton(
                      onPressed: () {
                        socketManager.sendMessage(
                            int.parse(widget.roomId), chatController.text);
                        chatController.text = "";
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
