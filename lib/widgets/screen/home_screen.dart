import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:app_team1/widgets/utils/infinite_scroll_mixin.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

  @override
  void initState() {
    initializeScrollController(_scrollController, _fetchRoomList);
    _fetchRoomList(isReload: true);
    _fetchTopicList();
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkExpiredRooms();
    });
  }

  _checkExpiredRooms() {
    final now = DateTime.now();
    setState(() {
      _roomList.removeWhere((room) {
        final DateTime endTime = room.endTime.toLocal();
        final bool isExpired = endTime.isBefore(now);
        return isExpired;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                              setState(() {
                                _roomList[index].isReserved =
                                    !_roomList[index].isReserved;
                              });
                            },
                            child: const Text('예약'),
                          ),
                        ),
                        const SizedBox(height: 4),
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
