import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Room> roomList = [];
  List<Topic> topicList = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    fetchRoomList();
    fetchTopicList();
    super.initState();
  }

  Future<void> fetchRoomList() async {
    roomList = await apiService.getRoomList(100);
    setState(() {});
  }

  Future<void> fetchTopicList() async {
    topicList = await apiService.getTopicList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: roomList.length,
        itemBuilder: (context, index) {
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
                    Text(
                        "주제: ${topicList.firstWhere((topic) => topic.id == roomList[index].topicId).name}"),
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
                    Text("시작: ${roomList[index].startTime.toIso8601String()}"),
                    const SizedBox(
                      height: 4,
                    ),
                    Text("종료: ${roomList[index].endTime.toIso8601String()}"),
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
