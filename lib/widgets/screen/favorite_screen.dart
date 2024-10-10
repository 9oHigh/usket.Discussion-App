import 'dart:async';
import 'package:app_team1/manager/toast_manager.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../model/room.dart';
import 'package:app_team1/model/topic.dart';
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

  @override
  void initState() {
    super.initState();
    initializeScrollController(_scrollController, _fetchRoomList);
    _initailizeRoomList();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  _initailizeRoomList() async {
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
        return endTime.isBefore(now);
      });
    });
  }

  Future<void> _fetchTopicList() async {
    _topicList = await _apiService.getTopicList();
    setState(() {});
  }

  _updateReservation(int index) async {
    ToastManager().showToast(
        context, "[${_reservedRoomList[index].roomName}] 토론방을 취소할게요.");
    setState(() {
      _reservedRoomList[index].saveIsReserved(false);
      _reservedRoomList.removeAt(index);
    });
  }

  Future<void> _fetchRoomList({bool? isReload}) async {
    if (isReload != null && isReload) {
      _reservedRoomList = await _apiService.getRoomList(null, 10);
      _reservedRoomList =
          _reservedRoomList.where((room) => room.isReserved).toList();
      if (_reservedRoomList.isNotEmpty) {
        cursorId = _reservedRoomList.last.roomId.toString();
      }
      setState(() {});
    } else {
      final toBeAddedRooms = await _apiService.getRoomList(cursorId, 10);
      if (toBeAddedRooms.isEmpty) {
        return;
      } else {
        _reservedRoomList += toBeAddedRooms;
        _reservedRoomList =
            _reservedRoomList.where((room) => room.isReserved).toList();
        if (_reservedRoomList.isNotEmpty) {
          cursorId = _reservedRoomList.last.roomId.toString();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _fetchRoomList(isReload: true),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _reservedRoomList.length,
          itemBuilder: (context, index) {
            String topicName = _topicList
                .firstWhere(
                    (topic) => topic.id == _reservedRoomList[index].topicId)
                .name;
            String startTime = DateFormat('yyyy-MM-dd HH:mm')
                .format(_reservedRoomList[index].startTime.toLocal());
            String endTime = DateFormat('yyyy-MM-dd HH:mm')
                .format(_reservedRoomList[index].endTime.toLocal());
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
                                onPressed: () => _updateReservation(index),
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
    );
  }
}
