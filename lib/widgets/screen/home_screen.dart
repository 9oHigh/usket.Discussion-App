import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:app_team1/widgets/utils/infinite_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../manager/toast_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with InfiniteScrollMixin<HomeScreen> {
  List<Room> _roomList = [];
  List<Topic> _topicList = [];
  Timer? _timer;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeScrollController(_scrollController, _fetchRoomList);
    _permissionWithNotification();
    _initializeNotifications();
    _initializeRoomList();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
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

  _initializeRoomList() async {
    await _fetchTopicList();
    await _fetchRoomList(isReload: true);
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkExpiredRooms();
    });
  }

  _checkExpiredRooms() async {
    final now = DateTime.now();
    setState(() {
      _roomList.removeWhere((room) {
        final DateTime startTime = room.startTime.toLocal();
        return startTime.isBefore(now);
      });
    });
  }

  Future<void> _fetchTopicList() async {
    _topicList = await _apiService.getTopicList();
    if (mounted) setState(() {});
  }

  Future<void> _fetchRoomList({bool? isReload}) async {
    final DateTime now = DateTime.now();

    if (isReload != null && isReload) {
      _roomList = await _apiService.getRoomList(null, 10);
      _roomList = _roomList
          .where((room) => !room.isReserved && now.isBefore(room.startTime))
          .toList();
      if (_roomList.isNotEmpty) {
        cursorId = _roomList.last.roomId.toString();
      }
      if (mounted) setState(() {});
    } else {
      final toBeAddedRooms = await _apiService.getRoomList(cursorId, 10);
      if (toBeAddedRooms.isEmpty) {
        return;
      } else {
        _roomList += toBeAddedRooms;
        _roomList = _roomList
            .where((room) => !room.isReserved && now.isBefore(room.startTime))
            .toList();
        if (_roomList.isNotEmpty) {
          cursorId = _roomList.last.roomId.toString();
        }
      }
    }
  }

  Future<void> _makeReservation(int index) async {
    ToastManager().showToast(context,
        "[${_roomList[index].roomName}] 토론방이 예약되었습니다.\n1분 전에 안내해드릴게요 :)");
    setState(() {
      _roomList[index].saveIsReserved(true);
      _roomList.removeAt(index);
    });
  }

  Future<void> _scheduleNotification(int index) async {
    DateTime startTime = _roomList[index].startTime;
    DateTime notificationTime = startTime.subtract(const Duration(minutes: 1));

    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(notificationTime, tz.local);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      _roomList[index].roomId,
      '방 예약 알림',
      '예약한 방이 1분 뒤에 시작합니다.',
      scheduledDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          '방 예약 알림 채널',
          '방 예약 알림',
          channelDescription: '방 예약 알림을 위한 채널',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방 목록'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final isSelected = await context.push("/filter");
              if (isSelected == true) {
                await _initializeRoomList();
              }
            },
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _scheduleNotification(index);
                              await _makeReservation(index);
                            },
                            child: const Text('예약'),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
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
    );
  }
}
