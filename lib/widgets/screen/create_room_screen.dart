import 'package:app_team1/manager/toast_manager.dart';

import '../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/topic.dart';
import 'package:go_router/go_router.dart';
import '../utils/text_button_style.dart';

enum CreateError {
  failCreate,
  insertRoomName,
  selectSuject,
  selectDate,
  selectTime,
}

extension on CreateError {
  String get message {
    switch (this) {
      case CreateError.failCreate:
        return "방 생성에 실패했습니다. 다시 시도해주세요.\nERROR: ";
      case CreateError.insertRoomName:
        return "방 이름을 입력해주세요.";
      case CreateError.selectSuject:
        return "주제를 선택해주세요.";
      case CreateError.selectDate:
        return "날짜를 선택해주세요.";
      case CreateError.selectTime:
        return "시간을 선택해주세요.";
    }
  }
}

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ApiService _apiService = ApiService();

  String _selectedDate = '';
  String _selectedTime = '';

  int? _selectedTopicId;
  String _selectedTopicName = '선택하기';

  Future<List<Topic>> _fetchTopicList() async {
    try {
      List<Topic> topicList = await _apiService.getTopicList();
      return topicList;
    } catch (error) {
      return [];
    }
  }

  Future<void> _createRoom() async {
    final DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse('$_selectedDate $_selectedTime')
        .toLocal();
    final DateTime endDateTime = dateTime.add(const Duration(hours: 1));

    try {
      await _apiService.createRoom(
        _selectedTopicId!,
        _roomNameController.text,
        0,
        dateTime.toUtc(),
        endDateTime.toUtc(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방이 성공적으로 생성되었습니다!'),
        ),
      );
    } catch (error) {
      _updateNotifyMessage(CreateError.failCreate, error: error);
    }
  }

  _updateNotifyMessage(CreateError createError, {dynamic error}) {
    String errorMessage =
        error != null ? "${createError.message} $error" : createError.message;
    ToastManager().showToast(context, errorMessage);
  }

  _showSubjecSelectDialog(BuildContext context) async {
    List<Topic> topicList = await _fetchTopicList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            topicList.isNotEmpty ? "주제를 선택하세요." : "주제가 없어요.",
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          // MARK: - Todo
          // 만약, 토픽이 화면에 모두 담길 수 없다면 카운트가 가장 높은 순으로 8개를 보여주고, 8개를 초과한다면
          // 하단에 토픽 생성 버튼을 만들어 관련 로직 구현해보기
          content: Wrap(
            // Wrap을 사용하면 최대 갯수만큼 집어 넣고 다음 행으로 표시된다.
            alignment: WrapAlignment.center,
            children: topicList.isNotEmpty
                ? topicList.map((topic) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        style: TextButtonStyles.textButtonStyle,
                        onPressed: () {
                          setState(() {
                            _selectedTopicId = topic.id;
                            _selectedTopicName = topic.name;
                          });
                          Navigator.of(context).pop();
                        },
                        child: Text(topic.name),
                      ),
                    );
                  }).toList()
                : [
                    const Center(
                      child: Text(
                        '주제를 생성해주세요.',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
          ),
        );
      },
    );
  }

  Future _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime lastDate = now.add(const Duration(days: 31));
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: lastDate,
    );

    setState(() {
      _selectedDate = selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate)
          : "";
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    setState(() {
      selectedTime != null
          ? _selectedTime =
              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double spaceBetweenColumns = screenHeight * 0.05;
    final double spaceBetweenElements = screenHeight * 0.015;
    final double textFieldWidth = screenWidth * 0.9;
    final double buttonWidth = screenWidth * 0.9;
    final double buttonHieght = screenHeight * 0.04;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop()),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_roomNameController.text.isEmpty) {
                  _focusNode.requestFocus();
                  _updateNotifyMessage(CreateError.insertRoomName);
                } else if (_selectedTopicId == null) {
                  _updateNotifyMessage(CreateError.selectSuject);
                } else if (_selectedDate.isEmpty) {
                  _updateNotifyMessage(CreateError.selectDate);
                } else if (_selectedTime.isEmpty) {
                  _updateNotifyMessage(CreateError.selectTime);
                } else {
                  setState(() {
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                  _createRoom().then((_) {
                    context.pop(true);
                  });
                }
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('방 이름'),
                  SizedBox(height: spaceBetweenElements),
                  SizedBox(
                    width: textFieldWidth,
                    child: TextField(
                      controller: _roomNameController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spaceBetweenColumns),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('주제 선택'),
                  SizedBox(height: spaceBetweenElements),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(buttonWidth, buttonHieght),
                      ),
                      onPressed: () => _showSubjecSelectDialog(context),
                      child: Text(_selectedTopicName))
                ],
              ),
              SizedBox(height: spaceBetweenColumns),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('날짜 선택'),
                  SizedBox(height: spaceBetweenElements),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(buttonWidth, buttonHieght)),
                    onPressed: () => _selectDate(context),
                    child: Text(
                      _selectedDate.isNotEmpty
                          ? _selectedDate
                          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    ),
                  )
                ],
              ),
              SizedBox(height: spaceBetweenColumns),
              Column(
                children: [
                  const Text('시간 선택'),
                  SizedBox(height: spaceBetweenElements),
                  ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text(_selectedTime.isNotEmpty
                          ? _selectedTime
                          : TimeOfDay.now().format(context)))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
