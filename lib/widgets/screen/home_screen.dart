import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:app_team1/widgets/utils/infinite_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../manager/toast_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with InfiniteScrollMixin<Room, HomeScreen> {
  List<Room> _roomList = [];
  List<Room> _reservedRoomList = [];
  List<Topic> _topicList = [];
  Timer? _timer;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _permissionWithNotification();
    _initializeNotifications();
    tz.initializeTimeZones();
    _startTimer();
    initializeScrollController(_scrollController, _fetchData);
    _fetchTopicList().then((_) {
      _fetchRoomList().then((_) {
        _loadReservations().then((_) {
          _fetchReservedRoomList();
        }); // 방 목록과 주제 목록이 로드된 후 호출
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTopicList() async {
    _topicList = await _apiService.getTopicList();
    setState(() {});
  }

  Future<List<Room>> _fetchData() async {
    final response = await _apiService.getRoomList(cursorId, 5);
    return response;
  }

  Future<void> _fetchRoomList() async {
    _roomList = await _apiService.getRoomList(cursorId, 5);
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkExpiredRooms();
    });
  }

  void _checkExpiredRooms() async {
    final now = DateTime.now();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _roomList.removeWhere((room) {  // _roomList에서 해당 room을 제거
        final DateTime endTime = room.endTime.toLocal();
        final bool isExpired = endTime.isBefore(now);
        if (isExpired) {
          // SharedPreferences에서도 해당 방의 예약 상태 삭제
          prefs.remove('room_${room.roomId}');
        }
        return isExpired;
      });
    });

    // _reservedRoomList에서도 만료된 방 제거
    _reservedRoomList.removeWhere((room) {
      final DateTime endTime = room.endTime.toLocal();
      return endTime.isBefore(now);
    });
  }

  Future<void> _updateReservation(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool currentReservationStatus = _roomList[index].isReserved;

    // 예약 상태 토글
    setState(() {
      _roomList[index].isReserved = !currentReservationStatus;
    });

    // SharedPreferences에 상태 저장
    await prefs.setBool(
        'room_${_roomList[index].roomId}', _roomList[index].isReserved);

    if (currentReservationStatus) {
      setState(() {
        _reservedRoomList
            .removeWhere((room) => room.roomId == _roomList[index].roomId);
      });
    } else {
      setState(() {
        _reservedRoomList.add(_roomList[index]);
      });
    }
  }

  // 예약 상태 불러오기
  Future<void> _loadReservations() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var room in _roomList) {
      room.isReserved = prefs.getBool('room_${room.roomId}') ?? false;
      print('방 "${room.roomName}" 예약 상태: ${room.isReserved}');
    }
    setState(() {});
  }

  // 예약된 방 리스트 불러오기
  Future<void> _fetchReservedRoomList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Room> allRooms = await _apiService.getRoomList(cursorId, 5);

    _reservedRoomList = allRooms.where((room) {
      room.isReserved = prefs.getBool('room_${room.roomId}') ?? false;
      return room.isReserved;
    }).toList();
    setState(() {});
  }

  // 권한 요청 메서드
  void _permissionWithNotification() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

  // 알림 초기화 메서드
  void _initializeNotifications() async {
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  // 방 시작 5분 전 알림 예약 메서드
  Future<void> _scheduleNotification(int index) async {
    // 인덱스 유효성 검사
    if (index < 0 || index >= _roomList.length) {
      print('유효하지 않은 인덱스입니다.');
      return;
    } else {
      print('방 예약 알림이 성공적으로 예약되었습니다.');
    }

    DateTime startTime = _roomList[index].startTime;
    DateTime notificationTime = startTime.subtract(const Duration(minutes: 5));

    // tz.TZDateTime으로 변환
    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(notificationTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        _roomList[index].roomId,
        '방 예약 알림',
        '예약한 방이 5분 뒤에 시작합니다.',
        scheduledDateTime,
        const NotificationDetails(
            android: AndroidNotificationDetails('방 예약 알림 채널', '방 예약 알림',
                channelDescription: '방 예약 알림을 위한 채널',
                importance: Importance.max,
                priority: Priority.high)),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  // 알림을 취소하는 메서드
  Future<void> _cancelNotification(int index) async {
    int notificationId = _roomList[index].roomId;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    print('알림이 취소되었습니다.');
  }

// 방의 시간대가 겹치는지 확인하는 메서드
  Future<bool> _checkTimeConflict(int index) async {
    final room = _roomList[index];
    DateTime startTime = room.startTime.toLocal();
    DateTime endTime = room.endTime.toLocal();

    print('새 방의 시작 시간: $startTime');
    print('새 방의 종료 시간: $endTime');
    print(_reservedRoomList);

    for (var reservedRoom in _reservedRoomList) {
      DateTime reservedStartTime = reservedRoom.startTime.toLocal();
      DateTime reservedEndTime = reservedRoom.endTime.toLocal();

      print('예약된 방의 시작 시간: $reservedStartTime');
      print('예약된 방의 종료 시간: $reservedEndTime');

      // 시간대가 겹치는지 확인
      if ((startTime.isBefore(reservedEndTime) &&
          endTime.isAfter(reservedStartTime))) {
        return true; // 충돌이 있을 경우 true 반환
      }
    }

    print('충돌이 없습니다.');
    return false; // 충돌이 없을 경우 false 반환
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _roomList.length,
        itemBuilder: (context, index) {
          String topicName = _topicList
              .firstWhere((topic) => topic.id == _roomList[index].topicId)
              .name;
          String startTime = DateFormat('yyyy-MM-dd HH:mm')
              .format(_roomList[index].startTime.toLocal());
          String endTime = DateFormat('yyyy-MM-dd HH:mm')
              .format(_roomList[index].endTime.toLocal());
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("주제: $topicName"),
                    const SizedBox(
                      height: 4,
                    ),
                    Text("방이름: ${_roomList[index].roomName}"),
                    const SizedBox(
                      height: 4,
                    ),
                    if (_roomList[index].isReserved) ...{
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[400]),
                              onPressed: () {},
                              child: const Text(
                                '참여',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _updateReservation(index).then((_) {
                                  _cancelNotification(index);
                                });
                              },
                              child: const Text('취소'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    } else ...{
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            _checkTimeConflict(index).then((hasConflict) {
                              if (!hasConflict) {
                                // 충돌이 없을 경우 예약 진행
                                _updateReservation(index).then((_) {
                                  _scheduleNotification(index);
                                });
                              } else {
                                // 충돌이 있을 경우 메시지 출력
                                ToastManager().showToast(
                                    context, '이 시간대에 이미 예약된 방이 있습니다!');
                              }
                            });
                          },
                          child: const Text('예약'),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    },
                    Text("시작: $startTime"),
                    const SizedBox(
                      height: 4,
                    ),
                    Text("종료: $endTime"),
                    const SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
