import 'package:app_team1/manager/notification_manager.dart';
import 'package:app_team1/manager/toast_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/topic/topic.dart';
import 'package:go_router/go_router.dart';
import 'styles/section_title_style.dart';
import 'styles/shadow_style.dart';
import 'widgets/app_bar.dart';
import 'widgets/time_picker.dart';
import '../core/app_color.dart';
import '../core/app_constant.dart';
import '../core/app_font_size.dart';
import '../utils/topic_mapped.dart';

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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ApiService _apiService = ApiService();

  List<Topic> _topicList = [];
  int? _selectedIndex;
  int? _selectedTopicId;

  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedTime = '';
  DateTime _calendarDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchTopicList();
  }

  Future<void> _fetchTopicList() async {
    try {
      _topicList = await _apiService.getTopicList();
      setState(() {});
    } catch (error) {
      ToastManager().showToast(context, "주제를 불러오는 데 실패했습니다.");
    }
  }

  Future<void> _createRoom() async {
    final DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse('$_selectedDate $_selectedTime')
        .toLocal();
    final DateTime endDateTime = dateTime.add(const Duration(hours: 1));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? playerId = prefs.getInt("playerId");

    if (playerId == null) {
      throw Exception("등록되지 않은 유저입니다.\n회원가입을 위해 재접속해주세요.");
    }

    try {
      final room = await _apiService.createRoom(
        _selectedTopicId!,
        _roomNameController.text,
        playerId,
        dateTime.toUtc(),
        endDateTime.toUtc(),
      );

      if (room != null) {
        await NotificationManager().scheduleNotification(room);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('방이 성공적으로 생성되었습니다!\n방이 시작되기 1분전에 알림을 보낼게요 :)'),
          ),
        );
      }
    } catch (error) {
      _showError(CreateError.failCreate, additionalMessage: error.toString());
    }
  }

  _showError(CreateError createError, {String? additionalMessage}) {
    String errorMessage = additionalMessage != null
        ? "${createError.message} $additionalMessage"
        : createError.message;
    ToastManager().showToast(context, errorMessage);
  }

  Future _updateSelectedDate(DateTime date) async {
    setState(() {
      _calendarDate = date;
      _selectedDate = DateFormat('yyyy-MM-dd').format(date);
    });
  }

  Future _updateSelectedTime(DateTime time) async {
    setState(() {
      _selectedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColor.backgroundColor,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColor.appBarContentsColor,
            ),
            onPressed: () => context.pop(),
          ),
          title: 'CREATE ROOM',
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.check, color: AppColor.appBarContentsColor),
              onPressed: () {
                if (_roomNameController.text.isEmpty) {
                  _focusNode.requestFocus();
                  _showError(CreateError.insertRoomName);
                } else if (_selectedTopicId == null) {
                  _showError(CreateError.selectSuject);
                } else if (_selectedDate.isEmpty) {
                  _showError(CreateError.selectDate);
                } else if (_selectedTime.isEmpty) {
                  _showError(CreateError.selectTime);
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
        body: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Center(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: AppConstant.getScreenHeight(context) * 0.03),
                      const Text('방 제목',
                          style: SectionTitleStyle.sectionTitleStyle),
                      SizedBox(height: AppConstant.spaceSmall(context)),
                      SizedBox(
                        width: AppConstant.textFieldWidth(context),
                        child: Container(
                          decoration: createShadowStyle(),
                          child: TextField(
                            controller: _roomNameController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(
                                    color: AppColor.primaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              hintText: '방 제목을 입력해주세요.',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstant.spaceMedium(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text('주제 선택',
                            style: SectionTitleStyle.sectionTitleStyle),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _topicList.isEmpty
                            ? const Center(
                                child: Text(
                                  '주제를 불러오는 데 실패했습니다.',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )
                            : SizedBox(
                                height:
                                    AppConstant.getScreenHeight(context) * 0.25,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: _topicList.length,
                                  itemBuilder: (context, index) {
                                    bool isSelected = _selectedIndex == index;
                                    Color boxColor = isSelected
                                        ? AppColor.thirdaryColor
                                        : Colors.white;
                                    Color topicNameColor = isSelected
                                        ? Colors.white
                                        : Colors.black;

                                    return Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            setState(() {
                                              _selectedIndex = index;
                                              if (_selectedIndex != null) {
                                                _selectedTopicId =
                                                    _topicList[_selectedIndex!]
                                                        .id;
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: createShadowStyle(
                                                color: boxColor),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  (isSelected
                                                          ? topicImageMap['${_topicList[index].name}-selected']?.image(
                                                              width: AppConstant
                                                                  .filterImageSize(
                                                                      context),
                                                              height: AppConstant
                                                                  .filterImageSize(
                                                                      context),
                                                              fit: BoxFit.cover)
                                                          : topicImageMap[
                                                                  _topicList[
                                                                          index]
                                                                      .name]
                                                              ?.image(
                                                                  width: AppConstant
                                                                      .filterImageSize(
                                                                          context),
                                                                  height: AppConstant
                                                                      .filterImageSize(
                                                                          context),
                                                                  fit: BoxFit
                                                                      .cover)) ??
                                                      Container(),
                                                  Text(
                                                    topicNameMap[
                                                            _topicList[index]
                                                                .name] ??
                                                        '기타',
                                                    style: TextStyle(
                                                      color: topicNameColor,
                                                      fontSize: AppFontSize
                                                          .filterTextSize,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstant.spaceMedium(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('날짜 선택',
                          style: SectionTitleStyle.sectionTitleStyle),
                      SizedBox(height: AppConstant.spaceSmall(context)),
                      Container(
                        decoration: createShadowStyle(),
                        child: CalendarDatePicker(
                          initialDate: _calendarDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 31)),
                          onDateChanged: _updateSelectedDate,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstant.spaceMedium(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('시간 선택',
                          style: SectionTitleStyle.sectionTitleStyle),
                      SizedBox(height: AppConstant.spaceSmall(context)),
                      Container(
                          decoration: createShadowStyle(),
                          child: TimePicker(onTimeChange: (time) {
                            _updateSelectedTime(time);
                          })),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
