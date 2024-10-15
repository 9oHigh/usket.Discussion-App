import 'dart:async';
import 'package:app_team1/manager/socket_manager.dart';
import 'package:app_team1/manager/toast_manager.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/room.dart';
import 'package:app_team1/model/topic/topic.dart';
import '../../widgets/utils/infinite_scroll_mixin.dart';
import 'package:intl/intl.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with InfiniteScrollMixin<FavoriteScreen> {
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
    initializeScrollController(_scrollController, _fetchRoomList);
    _initializeRoomList();
    _startTimer();
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

  _initializeRoomList() async {
    await _fetchTopicList();
    await _fetchRoomList(isReload: true);
  }

  _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkExpiredRooms();
    });
  }

  _checkExpiredRooms() {
    final now = DateTime.now();
    setState(() {
      _reservedRoomList.removeWhere((room) {
        final DateTime endTime = room.endTime.toLocal();
        final bool willDisapear = endTime.isBefore(now);
        if (willDisapear) {
          SocketManager().exitRoom(
            room.roomId.toString(),
          );
        }
        return willDisapear;
      });
    });
  }

  _updateReservation(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int playerId = prefs.getInt("playerId") ?? 0;
    final int roomId = _reservedRoomList[index].roomId;

    if (_reservedRoomList[index].playerId == playerId) {
      try {
        await _apiService.deleteRoom(roomId);
        ToastManager().showToast(
            context, "[${_reservedRoomList[index].roomName}] 토론방을 취소했습니다.");
        setState(() {
          _fetchRoomList(isReload: true);
        });
      } catch (e) {
        ToastManager().showToast(context,
            "[${_reservedRoomList[index].roomName}] 토론방을 취소하지 못했어요.\n다시 시도해주세요.");
      }
    } else {
      ToastManager().showToast(
          context, "[${_reservedRoomList[index].roomName}] 토론방을 취소했습니다.");
      setState(() {
        _reservedRoomList[index].saveIsReserved(false);
        _reservedRoomList.removeAt(index);
      });
    }
  }

  bool _canParticipate(int index) {
    final now = DateTime.now();
    final startTime = _reservedRoomList[index].startTime;
    final endTime = _reservedRoomList[index].endTime;
    final bool isStarted = now.isAfter(startTime) && now.isBefore(endTime);
    return isStarted;
  }

  Future<void> _cancelNotification(int index) async {
    int notificationId = _reservedRoomList[index].roomId;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> _fetchTopicList() async {
    _topicList = await _apiService.getTopicList();
    if (mounted) setState(() {});
  }

  Future<void> _fetchRoomList({bool? isReload}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int playerId = prefs.getInt("playerId") ?? 0;

    if (isReload != null && isReload) {
      _reservedRoomList = await _apiService.getRoomList(null, 10);
      _reservedRoomList = _reservedRoomList
          .where((room) => room.isReserved || room.playerId == playerId)
          .map((room) => Room.toReservedRoom(room))
          .toList();
      if (_reservedRoomList.isNotEmpty) {
        cursorId = _reservedRoomList.last.roomId.toString();
      }
      if (mounted) setState(() {});
    } else {
      final toBeAddedRooms = await _apiService.getRoomList(cursorId, 10);
      if (toBeAddedRooms.isEmpty) {
        return;
      } else {
        _reservedRoomList += toBeAddedRooms;
        _reservedRoomList = _reservedRoomList
            .where((room) => room.isReserved || room.playerId == playerId)
            .toList();
        if (_reservedRoomList.isNotEmpty) {
          cursorId = _reservedRoomList.last.roomId.toString();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이'),
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
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _reservedRoomList.length + 1,
            itemBuilder: (context, index) {
              if (index == _reservedRoomList.length) {
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
                  .firstWhere(
                      (topic) => topic.id == _reservedRoomList[index].topicId)
                  .name;
              String startTime = DateFormat('yyyy-MM-dd HH:mm')
                  .format(_reservedRoomList[index].startTime.toLocal());
              String endTime = DateFormat('yyyy-MM-dd HH:mm')
                  .format(_reservedRoomList[index].endTime.toLocal());
              bool canParticipate = _canParticipate(index);
              int roomId = _reservedRoomList[index].roomId;
              String roomName = _reservedRoomList[index].roomName;

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
                        Text("방이름: ${_reservedRoomList[index].roomName}"),
                        const SizedBox(
                          height: 4,
                        ),
                        if (_reservedRoomList[index].isReserved) ...{
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: canParticipate
                                          ? Colors.blue[400]
                                          : Colors.grey),
                                  onPressed: () async {
                                    if (canParticipate) {
                                      SocketManager().joinRoom(roomId);
                                      final timeOver = await context.push(
                                          '/chat/${roomId.toString()}/$roomName/${_reservedRoomList[index].endTime.toLocal().toIso8601String()}');
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _updateReservation(index);
                                    _cancelNotification(index);
                                    SocketManager().exitRoom(
                                      _reservedRoomList[index]
                                          .roomId
                                          .toString(),
                                    );
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
                              onPressed: () => _updateReservation(index),
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
        ),
      ),
    );
  }
}
