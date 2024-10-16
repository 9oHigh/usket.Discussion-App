import 'package:app_team1/manager/toast_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/topic/topic.dart';
import 'package:go_router/go_router.dart';

import '../styles/ui_styles.dart';
import '../utils/constants.dart';
import '../app_bar.dart';
import '../utils/picker.dart';

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

  List<Topic> _topicList = [];
  int? _selectedIndex;

  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedTime = '';
  DateTime _calendarDate = DateTime.now();

  int? _selectedTopicId;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchTopicList();
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

  Future<void> _fetchTopicList() async {
    try {
      List<Topic> topicList = await _apiService.getTopicList();
      setState(() {
        _topicList = topicList;
      });
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

    try {
      if (playerId == null) {
        throw Exception("등록되지 않은 유저입니다.\n회원가입을 위해 재접속해주세요.");
      }

      await _apiService.createRoom(
        _selectedTopicId!,
        _roomNameController.text,
        playerId,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.appBarContentsColor,
            ),
            onPressed: () => context.pop(),
          ),
          title: 'CREATE ROOM',
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.check, color: AppColors.appBarContentsColor),
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
                          height: AppConstants.getScreenHeight(context) * 0.03),
                      const Text('방 제목',
                          style: SectionTitleStyle.sectionTitleStyle),
                      SizedBox(
                          height: AppConstants.spaceSmall(context)),
                      SizedBox(
                        width: AppConstants.textFieldWidth(context),
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
                                    color: AppColors.primaryColor, width: 2),
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
                  SizedBox(height: AppConstants.spaceMedium(context)),
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
                            : Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 12.0,
                                  runSpacing: 12.0,
                                  children:
                                      List.generate(_topicList.length, (index) {
                                    bool isSelected = _selectedIndex == index;
                                    Color boxColor = isSelected
                                        ? AppColors.thirdaryColor
                                        : Colors.white;
                                    Color topicNameColor = isSelected
                                        ? Colors.white
                                        : Colors.black;
                                    return GestureDetector(
                                      onTap: () {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        setState(() {
                                          if (_selectedIndex != null &&
                                              _selectedIndex == index) {
                                            _selectedIndex = null;
                                          } else {
                                            _selectedIndex = index;
                                          }
                                          _selectedTopicId =
                                              _topicList[index].id;
                                        });
                                      },
                                      child: Container(
                                        width:
                                            AppConstants.topicBoxSize(context),
                                        height:
                                            AppConstants.topicBoxSize(context),
                                        decoration:
                                            createShadowStyle(color: boxColor),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              (_selectedIndex == index
                                                      ? topicImageMap[
                                                              '${_topicList[index].name}-selected']
                                                          ?.image(
                                                          width: AppConstants
                                                              .filterImageSize(
                                                                  context),
                                                          height: AppConstants
                                                              .filterImageSize(
                                                                  context),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : topicImageMap[
                                                              _topicList[index]
                                                                  .name]
                                                          ?.image(
                                                          width: AppConstants
                                                              .filterImageSize(
                                                                  context),
                                                          height: AppConstants
                                                              .filterImageSize(
                                                                  context),
                                                          fit: BoxFit.cover,
                                                        )) ??
                                                  Container(),
                                              Text(
                                                topicNameMap[_topicList[index]
                                                        .name] ??
                                                    '기타',
                                                style: TextStyle(
                                                    color: topicNameColor,
                                                    fontSize: AppFontSizes
                                                        .filterTextSize,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.spaceMedium(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('날짜 선택',
                          style: SectionTitleStyle.sectionTitleStyle),
                      SizedBox(
                          height: AppConstants.spaceSmall(context)),
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
                  SizedBox(height: AppConstants.spaceMedium(context)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('시간 선택',
                          style: SectionTitleStyle.sectionTitleStyle),
                      SizedBox(
                          height: AppConstants.spaceSmall(context)),
                      Container(
                        decoration: createShadowStyle(),
                        child: TimePicker(onTimeChange: (time){
                          _updateSelectedTime(time);
                        })
                      ),
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
