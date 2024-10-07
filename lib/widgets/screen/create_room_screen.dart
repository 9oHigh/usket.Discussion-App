import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../model/topic.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ApiService _apiService = ApiService();

  String notifyText = "";
  String _selectedDate = '';
  String _selectedTime = '';
  int? _selectedTopicId;
  String _selectedTopicName = '선택하기';

  // 방 생성 메서드
  Future<void> createRoom() async {
    try {
      // 날짜와 시간 문자열을 DateTime 객체로 변환
      final dateTime =
          DateFormat('yyyy-MM-dd HH:mm').parse('$_selectedDate $_selectedTime');
      final endDateTime = dateTime.add(const Duration(hours: 2)); // 2시간 후 종료

      bool result = await _apiService.createRoom(_selectedTopicId!,
          _roomNameController.text, 0, dateTime, endDateTime);

      if (result) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('방이 성공적으로 생성되었습니다!')));
        // Navigator.pop(context); // 방 생성 후 이전 화면으로 돌아가기, 병합 후 주석 해제
      } else {
        setState(() {
          notifyText = "방 생성에 실패했습니다. 다시 시도해주세요.";
        });
      }
    } catch (e) {
      setState(() {
        notifyText = "오류가 발생했습니다: ${e.toString()}";
      });
    }
  }

  // 주제 목록을 가져오는 함수

  // ApiService의 인스턴스 생성
  final apiService = ApiService();

  Future<List<Topic>> fetchTopicList() async {
    try {
      List<Topic> topicList = await apiService.getTopicList();
      for (var topic in topicList) {
        print('ID: ${topic.id}, Name: ${topic.name}');
      }
      return topicList; // 주제 리스트 반환
    } catch (e) {
      print('Failed to fetch topics: $e');
      return []; // 실패 시 빈 리스트 반환
    }
  }

  // === 주제 선택 메서드
  void subjecSelectDialog(BuildContext context) async {
    List<Topic> topicList = await fetchTopicList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double modalHeight = screenHeight * 0.17;

        return Dialog(
          child: SizedBox(
            height: modalHeight,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "주제를 선택하세요.",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // 주제 리스트를 기반으로 버튼 생성
                  if (topicList.isNotEmpty) ...[
                    Row(
                      children: topicList.map((topic) {
                        return Row(
                          children: [
                            TextButton(
                              style: TextButtonStyles.textButtonStyle,
                              onPressed: () {
                                setState(() {
                                  _selectedTopicId = topic.id; // 선택한 토픽의 ID를 할당
                                  _selectedTopicName =
                                      topic.name; // 선택한 토픽의 이름을 할당
                                });
                                Navigator.of(context).pop(); // 대화상자 닫기
                              },
                              child: Text(topic.name), // 버튼 텍스트로 토픽 이름 사용
                            ),
                            const SizedBox(width: 5),
                          ],
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    // 주제 목록이 없을 경우 사용자에게 알림
                    const Center(
                      child: Text('주제 목록이 없습니다.',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // === 날짜 선택 메서드
  Future _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(selected);
      });
    }
  }

  // === 시간 선택 메서드
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        // 선택한 시간을 문자열로 포맷팅
        _selectedTime =
            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // ===== 크기 변수 =====
    final double spaceBetweenColumns = screenHeight * 0.05;
    final double spaceBetweenElements = screenHeight * 0.015;
    final double textFieldWidth = screenWidth * 0.9;
    final double buttonWidth = screenWidth * 0.9;
    final double buttonHieght = screenHeight * 0.04;

    // 포커스 상태 확인 함수
    void handleFocusChange() {
      if (focusNode.hasFocus) {
        debugPrint('##### focus on #####');
      } else {
        debugPrint('##### focus off #####');
      }
    }

    // 포커스 상태 확인을 위한 리스너
    focusNode.addListener(() => handleFocusChange);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check), // 방 생성 체크 버튼
              onPressed: () {
                // 텍스트필드에 입력 내용 확인
                if (_roomNameController.text.isEmpty) {
                  // 내용이 없으면 포커스를 텍스트필드로 이동하고 알림 메시지 출력
                  focusNode.requestFocus();
                  setState(() => notifyText = "방 이름을 입력해주세요.");
                } else if (_selectedTopicId == null) {
                  setState(() => notifyText = "주제를 선택해주세요.");
                } else if (_selectedDate.isEmpty) {
                  setState(() => notifyText = "날짜를 선택해주세요.");
                } else if (_selectedTime.isEmpty) {
                  setState(() => notifyText = "시간을 선택해주세요.");
                } else {
                  setState(() {
                    notifyText = "";
                    // 체크 버튼 클릭 시 입력이 유효할 경우에만 포커스를 해제
                    FocusManager.instance.primaryFocus?.unfocus(); // 포커스 해제
                  });
                  // 모든 조건이 충족되면 createRoom 메서드 호출
                  createRoom();
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
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Text(notifyText, style: const TextStyle(color: Colors.red))
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
                          minimumSize: Size(buttonWidth, buttonHieght)),
                      onPressed: () {
                        subjecSelectDialog(context);
                      },
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
                    child: Text(_selectedDate.isNotEmpty
                        ? _selectedDate
                        : DateFormat('yyyy-MM-dd').format(DateTime.now())),
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

class TextButtonStyles {
  // TextButton 스타일 정의
  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // 모서리 둥글기
      side: const BorderSide(color: Colors.grey, width: 1), // 테두리
    ),
  );
}
