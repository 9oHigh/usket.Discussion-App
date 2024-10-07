import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Room> roomList = [];
  List<Topic> topicList = [];
  ApiService apiService = ApiService();
  Timer? timer;

  @override
  void initState() {
    fetchRoomList();
    fetchTopicList();
    super.initState();
    startTimer(); // 타이머 시작
  }

  @override
  void dispose() {
    timer?.cancel(); // 타이머 종료
    super.dispose();
  }

  Future<void> fetchRoomList() async {
    roomList = await apiService.getRoomList(100);
    setState(() {});
  }

  Future<void> fetchTopicList() async {
    topicList = await apiService.getTopicList();
    setState(() {});
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      checkExpiredRooms();
    });
  }

  void checkExpiredRooms() {
    final now = DateTime.now().toUtc();
    print("현재 시간 (UTC): ${now.toIso8601String()}");

    setState(() {
      roomList.removeWhere((room) {
        // endTime이 DateTime 객체인지 확인
        DateTime endTimeUtc = room.endTime.toUtc();

        bool isExpired = endTimeUtc.isBefore(now);

        // 시간 차이 계산
        Duration difference = now.difference(endTimeUtc);
        print("시간 차이 (초): ${difference.inSeconds}");

        if (isExpired) {
          print("삭제되는 방: ${room.roomName}, 종료 시간: ${room.endTime}");
        } else {
          print(
              "유지되는 방: ${room.roomName}, 종료까지 남은 시간: ${-difference.inMinutes} 분");
        }

        return isExpired;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: roomList.length,
        itemBuilder: (context, index) {
          String topicName;

          try {
            topicName = topicList
                .firstWhere(
                  (topic) => topic.id == roomList[index].topicId,
                )
                .name;
          } catch (e) {
            topicName = '주제 없음'; // 예외 발생 시 기본값 설정
          }

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
                    Text("방이름: ${roomList[index].roomName}"),
                    const SizedBox(
                      height: 4,
                    ),
                    if (roomList[index].isReserved) ...{
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
                                setState(() {
                                  roomList[index].isReserved =
                                      !roomList[index].isReserved;
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
                            setState(() {
                              roomList[index].isReserved =
                                  !roomList[index].isReserved;
                            });
                          },
                          child: const Text('예약'),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    },
                    Text(
                        "시작: ${DateFormat('yyyy-MM-dd HH:mm').format(roomList[index].startTime)}"),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                        "종료: ${DateFormat('yyyy-MM-dd HH:mm').format(roomList[index].endTime)}"),
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
