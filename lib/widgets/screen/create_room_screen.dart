import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷 패키지 추가

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _controller = TextEditingController();

  // ==== 날짜 포맷 ==== 
  String formatDate = '';
  String formatTime = '';

  
  // ==== 텍스트 입력 관련 알림 메시지 ====
  String notifyText = "";

  @override
  void initState() {
    super.initState();
    checkTime(); // 페이지 로드 시 현재 시간 체크
  }

  // ===== 현재 시간을 확인하는 메서드 =====
  void checkTime() {
    var now = DateTime.now();
    setState(() {
      formatDate = DateFormat('y-M-d').format(now).toString();
      formatTime =
          DateFormat('hh:mm').format(now).toString(); // 12시간 형식으로 시간 포맷
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // ===== 크기 변수 =====
    final double spaceBetweenColumns = screenHeight * 0.05;
    final double spaceBetweenElements = screenHeight * 0.015;
    final double TextFieldWidth = screenWidth * 0.9;
    final double buttonWidth = screenWidth * 0.9;
    final double buttonHieght = screenHeight * 0.04;

    // 텍스트필드의 포커스노드
    final FocusNode focusNode = FocusNode();

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

    @override
    void dispose() {
      // dispose 단계에서 포커스 노드 및 리스너 제거
      focusNode.removeListener(handleFocusChange);
      focusNode.dispose();

      super.dispose();
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // 뒤로 가기 아이콘
            onPressed: () {
              Navigator.pop(context); // 이전 페이지로 돌아가기
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check), // 체크 아이콘
              onPressed: () {
                // 체크 버튼 클릭 시 수행할 작업

                // 텍스트필드에 입력 내용 확인
                if (_controller.text == "") {
                  // 내용이 없으면 포커스를 텍스트필드로 이동하고 알림 메시지 출력
                  focusNode.requestFocus();
                  setState(() => notifyText = "방 이름을 입력해주세요.");
                } else {
                  setState(() {
                  notifyText = "";
                  // 체크 버튼 클릭 시 입력이 유효할 경우에만 포커스를 해제
                  FocusManager.instance.primaryFocus?.unfocus(); // 포커스 해제
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
                    width: TextFieldWidth,
                    child: TextField(
                      controller: _controller,
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
                      child: const Text('선택하기'))
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
                      onPressed: () {},
                      child: Text(formatDate))
                ],
              ),
              SizedBox(height: spaceBetweenColumns),
              Column(
                children: [
                  const Text('시간 선택'),
                  SizedBox(height: spaceBetweenElements),
                  ElevatedButton(onPressed: () {}, child: Text(formatTime))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

void subjecSelectDialog(context) {
  showDialog(
    context: context,
    builder: (context) {
      final double screenHeight = MediaQuery.of(context).size.height;
      final double modalHieght = screenHeight * 0.17;

      return Dialog(
        child: SizedBox(
          height: modalHieght,
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
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Row(
                  children: [
                    TextButton(
                        style: TextButtonStyles.textButtonStyle,
                        onPressed: () {},
                        child: const Text('토픽1')),
                    const SizedBox(
                      width: 5,
                    ),
                    TextButton(
                        style: TextButtonStyles.textButtonStyle,
                        onPressed: () {},
                        child: const Text('토픽2')),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateRoomScreen(),
    );
  }
}
