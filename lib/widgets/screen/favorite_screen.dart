import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import '../../model/room.dart';
import 'package:app_team1/model/topic.dart';
import '../../widgets/utils/infinite_scroll_mixin.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with InfiniteScrollMixin<Room, FavoriteScreen> {
  List<Room> _roomList = [];
  List<Topic> _topicList = [];

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeScrollController(_scrollController, _fetchData);
    _fetchTopicList().then((_) {
      _fetchReservedRoomList();
    });
  }

  @override
  void dispose() {
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

  void _updateReservation(int index) async {
    setState(() {
      _roomList[index].isReserved = !_roomList[index].isReserved;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'room_${_roomList[index].roomId}', _roomList[index].isReserved);

    // 예약이 취소된 경우 방 목록에서 제거
    setState(() {
      _roomList.removeAt(index);
    });
  }


  // 예약된 방 필터링
  Future<void> _fetchReservedRoomList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Room> allRooms =
        await _apiService.getRoomList(cursorId, 5);

    _roomList = allRooms.where((room) {
      room.isReserved = prefs.getBool('room_${room.roomId}') ?? false;
      return room.isReserved; 
    }).toList(); // 예약된 방만 반환해서 리스트로 변환

    setState(() {}); // UI 업데이트
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
                                _updateReservation(index);
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
                            _updateReservation(index);
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
