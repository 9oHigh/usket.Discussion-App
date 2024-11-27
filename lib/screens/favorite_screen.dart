import 'dart:async';
import 'package:app_team1/manager/notification_manager.dart';
import 'package:app_team1/manager/socket_manager.dart';
import 'package:app_team1/manager/toast_manager.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/room.dart';
import 'package:app_team1/model/topic/topic.dart';
import 'styles/shadow_style.dart';
import '../core/app_color.dart';
import '../core/app_constant.dart';
import '../core/app_font_size.dart';
import '../utils/mixin/infinite_scroll_mixin.dart';
import 'package:intl/intl.dart';
import 'widgets/app_bar.dart';
import '../gen/fonts.gen.dart';
import '../utils/topic_mapped.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with InfiniteScrollMixin<FavoriteScreen> {
  List<Room> _reservedRooms = [];
  List<Topic> _topicList = [];
  Timer? _timer;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeScrollController(_scrollController, _fetchRoomList);
    _initializeRoomList();
    _startRoomExpirationTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reloadRoomList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  _reloadRoomList() {
    setState(() {
      _fetchTopicList();
      _fetchRoomList(isReload: true);
    });
  }

  Future<void> _initializeRoomList() async {
    await _fetchTopicList();
    await _fetchRoomList(isReload: true);
  }

  Future<void> _fetchTopicList() async {
    _topicList = await _apiService.getTopicList();
    if (mounted) setState(() {});
  }

  Future<void> _fetchRoomList({bool isReload = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int playerId = prefs.getInt("playerId") ?? 0;
    List<Room> fetchedRooms =
        await _apiService.getRoomList(isReload ? null : cursorId, 100);

    if (fetchedRooms.isEmpty) return;

    List<Room> filteredRooms = fetchedRooms
        .where((room) => room.isReserved || room.playerId == playerId)
        .map((room) => Room.toReservedRoom(room))
        .toList();

    _reservedRooms = isReload ? filteredRooms : _reservedRooms += filteredRooms;
    cursorId = _reservedRooms.isNotEmpty
        ? _reservedRooms.last.roomId.toString()
        : null;

    if (mounted && isReload) setState(() {});
  }

  _startRoomExpirationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _removeExpiredRooms();
    });
  }

  _removeExpiredRooms() {
    final now = DateTime.now();
    setState(() {
      _reservedRooms.removeWhere((room) {
        final DateTime endTime = room.endTime.toLocal();
        final bool isExpired = endTime.isBefore(now);
        if (isExpired) {
          SocketManager().exitRoom(room.roomId.toString());
        }
        return isExpired;
      });
    });
  }

  _updateReservation(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int playerId = prefs.getInt("playerId") ?? 0;
    final int roomId = _reservedRooms[index].roomId;

    if (_reservedRooms[index].playerId == playerId) {
      try {
        await _apiService.deleteRoom(roomId);
        ToastManager().showToast(
            context, "[${_reservedRooms[index].roomName}] 토론방을 취소했습니다.");
        setState(() {
          _fetchRoomList(isReload: true);
        });
      } catch (e) {
        ToastManager().showToast(context,
            "[${_reservedRooms[index].roomName}] 토론방을 취소하지 못했어요.\n다시 시도해주세요.");
      }
    } else {
      ToastManager().showToast(
          context, "[${_reservedRooms[index].roomName}] 토론방을 취소했습니다.");
      await _reservedRooms[index].saveIsReserved(false);
      setState(() {
        _reservedRooms.removeAt(index);
      });
    }
  }

  bool _canParticipate(int index) {
    final now = DateTime.now();
    final startTime = _reservedRooms[index].startTime;
    final endTime = _reservedRooms[index].endTime;
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: CustomAppBar(
        title: 'MY ROOM LIST',
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
            itemCount: _reservedRooms.length + 1,
            itemBuilder: (context, index) {
              if (index == _reservedRooms.length) {
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
                  .firstWhere(
                      (topic) => topic.id == _reservedRooms[index].topicId)
                  .name;
              String startTime = DateFormat('MM/dd HH:mm')
                  .format(_reservedRooms[index].startTime.toLocal());
              String endTime = DateFormat('MM/dd HH:mm')
                  .format(_reservedRooms[index].endTime.toLocal());
              bool canParticipate = _canParticipate(index);
              int roomId = _reservedRooms[index].roomId;
              String roomName = _reservedRooms[index].roomName;

              return Padding(
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
                                  Container(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Text(
                                          overflow: TextOverflow.ellipsis,
                                          _reservedRooms[index].roomName,
                                          style: const TextStyle(
                                              fontSize:
                                                  AppFontSize.titleTextSize,
                                              fontFamily:
                                                  FontFamily.spoqaHanSansNeo))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_reservedRooms[index].isReserved) ...{
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: canParticipate
                                          ? AppColor.primaryColor
                                          : Colors.grey),
                                  onPressed: () async {
                                    if (canParticipate) {
                                      SocketManager().joinRoom(roomId);
                                      final timeOver = await context.push(
                                          '/chat/${roomId.toString()}/$roomName/${_reservedRooms[index].endTime.toLocal().toIso8601String()}');
                                      if (timeOver == true) {
                                        await _initializeRoomList();
                                      }
                                    } else {
                                      ToastManager().showToast(context,
                                          "아직 참여할 수 없어요.\n시간을 확인해주세요.");
                                    }
                                  },
                                  child: const Text(
                                    '참여',
                                    style: TextStyle(
                                        color: AppColor.buttonTextColor),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    _updateReservation(index);
                                    SocketManager().exitRoom(
                                      _reservedRooms[index].roomId.toString(),
                                    );
                                    await NotificationManager()
                                        .cancelNotification(
                                            _reservedRooms[index]);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColor.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text('취소',
                                      style: TextStyle(
                                          color: AppColor.primaryColor)),
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
                              onPressed: () => _updateReservation(index),
                              child: const Text('예약'),
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                        },
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
