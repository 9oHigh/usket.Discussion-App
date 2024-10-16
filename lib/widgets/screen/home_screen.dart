import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:app_team1/widgets/utils/constants.dart';
import 'package:app_team1/widgets/utils/infinite_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../manager/toast_manager.dart';
import '../app_bar.dart';
import '../styles/ui_styles.dart';

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
    final DateTime now = DateTime.now();
    DateTime startTime = _roomList[index].startTime;
    DateTime notificationTime = startTime.subtract(const Duration(minutes: 1));

    tz.TZDateTime scheduledDateTime =
        tz.TZDateTime.from(notificationTime, tz.local);
    if (scheduledDateTime.isBefore(now)) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'ROOM LIST',
        actions: [
          IconButton(
            onPressed: () async {
              final isSelected = await context.push("/filter");
              if (isSelected == true) {
                await _initializeRoomList();
              }
            },
            icon: const Icon(Icons.filter_alt,
                color: AppColors.appBarContentsColor),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchRoomList(isReload: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
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
              String startTime = DateFormat('MM/dd HH:mm')
                  .format(_roomList[index].startTime.toLocal());
              String endTime = DateFormat('MM/dd HH:mm')
                  .format(_roomList[index].endTime.toLocal());
              return Padding(
                key: ValueKey(_roomList[index].roomId),
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: createShadowStyle(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            topicImageMap[topicName]?.image(
                                  width: AppConstants.listImageSize(context),
                                  height: AppConstants.listImageSize(context),
                                  fit: BoxFit.cover,
                                ) ??
                                Container(),
                            const SizedBox(
                              width: 8,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(topicNameMap[topicName] ?? topicName,
                                    style: const TextStyle(
                                        fontSize: AppFontSizes.topicTextSize,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(_roomList[index].roomName,
                                    style: const TextStyle(
                                      fontSize: AppFontSizes.titleTextSize,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () async {
                                  await _scheduleNotification(index);
                                  await _makeReservation(index);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: const Text('예약',
                                    style:
                                        TextStyle(color: AppColors.primaryColor)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Text("시작",
                                style: TextStyle(
                                    fontSize: AppFontSizes.timeTextSize,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(startTime,
                                style: const TextStyle(
                                    fontSize: AppFontSizes.timeTextSize,
                                    color: AppColors.thirdaryColor,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 1,
                              height: 10,
                              color: AppColors.thirdaryColor,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text("종료",
                                style: TextStyle(
                                    fontSize: AppFontSizes.timeTextSize,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(endTime,
                                style: const TextStyle(
                                    fontSize: AppFontSizes.timeTextSize,
                                    color: AppColors.thirdaryColor,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
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
        ),
      ),
    );
  }
}
