import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:app_team1/widgets/utils/infinite_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    with InfiniteScrollMixin<HomeScreen> {
  List<Room> _roomList = [];
  List<Room> _reservedRoomList = [];
  List<Topic> _topicList = [];
  Timer? _timer;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _permissionWithNotification();
    _inintializeRoomList();
    initializeScrollController(_scrollController, _fetchRoomList);
    _fetchRoomList(isReload: true);
    _fetchTopicList();
    _startTimer();
    _inintializeRoomList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  _inintializeRoomList() async {
    await _fetchTopicList();
    await _fetchRoomList();
    await _loadReservations();
    await _fetchReservedRoomList();
  }

  Future<void> _fetchRoomList({bool? isReload}) async {
    if (isReload != null && isReload) {
      _roomList = await _apiService.getRoomList(null, 10);
      cursorId = _roomList.last.roomId.toString();
      setState(() {});
    } else {
      final toBeAddedRooms = await _apiService.getRoomList(cursorId, 10);
      if (toBeAddedRooms.isEmpty) {
        return;
      } else {
        _roomList += toBeAddedRooms;
        cursorId = _roomList.last.roomId.toString();
      }
    }
  }

  Future<void> _fetchTopicList() async {
    _topicList = await _apiService.getTopicList();
    setState(() {});
  }

  _checkExpiredRooms() async {
    final now = DateTime.now();

    setState(() {
      _roomList.removeWhere((room) {
        final DateTime endTime = room.endTime.toLocal();
        return endTime.isBefore(now);
      });

      _reservedRoomList.removeWhere((room) {
        final DateTime endTime = room.endTime.toLocal();
        return endTime.isBefore(now);
      });
    });
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkExpiredRooms();
    });
  }

  Future<void> _updateReservation(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool currentReservationStatus = _roomList[index].isReserved;

    setState(() {
      _roomList[index].isReserved = !currentReservationStatus;
    });

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

  Future<void> _loadReservations() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var room in _roomList) {
      room.isReserved = prefs.getBool('room_${room.roomId}') ?? false;
    }
    setState(() {});
  }

  Future<void> _fetchReservedRoomList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Room> allRooms = await _apiService.getRoomList(cursorId, 5);

    _reservedRoomList = allRooms.where((room) {
      room.isReserved = prefs.getBool('room_${room.roomId}') ?? false;
      return room.isReserved;
    }).toList();
    setState(() {});
  }

  _permissionWithNotification() async {
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      await [Permission.notification].request();
    }
  }

  _initializeNotifications() async {
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _scheduleNotification(int index) async {
    if (index < 0 || index >= _roomList.length) {
      return;
    }

    DateTime startTime = _roomList[index].startTime;
    DateTime notificationTime = startTime.subtract(const Duration(minutes: 5));

    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(notificationTime, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
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

  Future<void> _cancelNotification(int index) async {
    int notificationId = _roomList[index].roomId;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<bool> _checkTimeConflict(int index) async {
    final room = _roomList[index];
    DateTime startTime = room.startTime.toLocal();
    DateTime endTime = room.endTime.toLocal();

    for (var reservedRoom in _reservedRoomList) {
      DateTime reservedStartTime = reservedRoom.startTime.toLocal();
      DateTime reservedEndTime = reservedRoom.endTime.toLocal();

      if ((startTime.isBefore(reservedEndTime) &&
          endTime.isAfter(reservedStartTime))) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _fetchRoomList(isReload: true),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _roomList.length + 1,
            itemBuilder: (context, index) {
              if (index == _roomList.length) {
                return isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink();
              }

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
                    key: ValueKey(_roomList[index].roomId),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("주제: $topicName"),
                        const SizedBox(height: 4),
                        Text("방이름: ${_roomList[index].roomName}"),
                        const SizedBox(height: 4),
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
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _roomList[index].isReserved =
                                          !_roomList[index].isReserved;
                                    });
                                  },
                                  child: const Text('취소'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        } else ...{
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                _checkTimeConflict(index).then((hasConflict) {
                                  if (!hasConflict) {
                                    _updateReservation(index).then((_) {
                                      _scheduleNotification(index);
                                    });
                                  } else {
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
                        const SizedBox(height: 4),
                        Text("종료: $endTime"),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isCreated = await context.push('/create_room');
          if (isCreated == true) _fetchRoomList(isReload: true);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
