import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:app_team1/widgets/utils/mixin/infinite_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../manager/toast_manager.dart';
import '../custom/style/shadow_style.dart';
import '../custom/widget/app_bar.dart';
import '../../gen/fonts.gen.dart';
import '../utils/app_color.dart';
import '../utils/app_constant.dart';
import '../utils/app_font_size.dart';
import '../utils/topic_mapped.dart';

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
    _initializPermission();
    _initializeNotifications();
    _initializeRoomList();
    _startRoomExpirationTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  _initializPermission() async {
    final permissionStatus = await Permission.notification.status;
    if (permissionStatus.isDenied && !permissionStatus.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }

  _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  _initializeRoomList() async {
    await _fetchTopicList();
    await _fetchRoomList(isReload: true);
  }

  _startRoomExpirationTimer() {
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _removeExpiredRooms());
  }

  _removeExpiredRooms() async {
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

  Future<void> _fetchRoomList({bool isReload = false}) async {
    final DateTime now = DateTime.now();
    List<Room> fetchedRooms =
        await _apiService.getRoomList(isReload ? null : cursorId, 10);

    if (fetchedRooms.isEmpty) return;

    final List<Room> filteredRoom = fetchedRooms
        .where((room) => !room.isReserved && now.isBefore(room.startTime))
        .toList();

    _roomList = isReload ? filteredRoom : _roomList += filteredRoom;
    cursorId = _roomList.isNotEmpty ? _roomList.last.roomId.toString() : null;
    if (mounted && isReload) setState(() {});
  }

  Future<void> _makeReservation(int index) async {
    final room = _roomList[index];
    ToastManager().showToast(
        context, "[${room.roomName}] 토론방이 예약되었습니다.\n1분 전에 안내해드릴게요 :)");
    setState(() {
      room.saveIsReserved(true);
      _roomList.removeAt(index);
    });

    await _scheduleNotification(room);
  }

  Future<void> _scheduleNotification(Room room) async {
    final DateTime now = DateTime.now();
    final notificationTime =
        room.startTime.subtract(const Duration(minutes: 1));
    final scheduledDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    if (scheduledDateTime.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        room.roomId,
        '방 예약 알림',
        '[${room.roomName}]방이 1분 뒤에 시작합니다!\n서둘러주세요 :)',
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
      backgroundColor: AppColor.backgroundColor,
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
                color: AppColor.appBarContentsColor),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColor.primaryColor,
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
                          child: CircularProgressIndicator(
                            color: AppColor.primaryColor,
                          ),
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
                                  width: AppConstant.listImageSize(context),
                                  height: AppConstant.listImageSize(context),
                                  fit: BoxFit.cover,
                                ) ??
                                Container(),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(topicNameMap[topicName] ?? topicName,
                                      style: const TextStyle(
                                          fontSize: AppFontSize.topicTextSize,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(_roomList[index].roomName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: AppFontSize.titleTextSize, fontFamily: FontFamily.spoqaHanSansNeo
                                      )),
                                ],
                              ),
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
                                  await _makeReservation(index);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColor.primaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: const Text('예약',
                                    style: TextStyle(
                                        color: AppColor.primaryColor)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Text("시작",
                                style: TextStyle(
                                    fontSize: AppFontSize.timeTextSize,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(startTime,
                                style: const TextStyle(
                                    fontSize: AppFontSize.timeTextSize,
                                    color: AppColor.thirdaryColor,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 1,
                              height: 10,
                              color: AppColor.thirdaryColor,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text("종료",
                                style: TextStyle(
                                    fontSize: AppFontSize.timeTextSize,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(endTime,
                                style: const TextStyle(
                                    fontSize: AppFontSize.timeTextSize,
                                    color: AppColor.thirdaryColor,
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
