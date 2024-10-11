import 'package:flutter/material.dart';
import '../../styles/constants.dart';
import 'package:go_router/go_router.dart';
import '../../model/topic.dart';
import '../../services/api_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<Topic> _topicList = [];
  final ApiService _apiService = ApiService();
  int? _selectedIndex;
  List<int> _roomCounts = [];

  @override
  void initState() {
    super.initState();
    _fetchTopicList();
  }

  Future<void> _fetchTopicList() async {
  try {
    _topicList = await _apiService.getTopicList();
    List<dynamic> roomCountsData = await _apiService.getTopicRoomCounts();
    
    Map<String, int> roomCountMap = {
      for (var item in roomCountsData)
        item['id'].toString(): int.parse(item['room_count'].toString())
    };
    
    _roomCounts = _topicList.map((topic) => 
      roomCountMap[topic.id.toString()] ?? 0
    ).toList();

    setState(() {});
  } catch (e) {
    print('오류가 발생했습니다.: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: const Align(
            alignment: Alignment.center, child: Text('Topic Filter')),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 20, 30),
        child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 12.0,
            runSpacing: 12.0,
            children: _topicList.isNotEmpty
                ? _topicList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Topic topic = entry.value;

                    return Stack(children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                             _selectedIndex = index;
                          });
                        },
                        child: Container(
                          width: AppConstants.topicBoxSize(context),
                          height: AppConstants.topicBoxSize(context),
                          decoration: BoxDecoration(
                            color: _selectedIndex == index ? Colors.blue : Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                              child: Text(
                            topic.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )),
                        ),
                      ),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                              alignment: Alignment.center,
                              width: AppConstants.badgeSize(context),
                              height: AppConstants.badgeSize(context),
                              decoration: BoxDecoration(
                                color: _selectedIndex == index ? Colors.white : Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_roomCounts[index]}',
                                style: TextStyle(
                                    color: _selectedIndex == index ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w500),
                              )))
                    ]);
                  }).toList()
                : [
                    const Center(
                      child: Text(
                        '주제를 불러오는 데 실패했습니다.',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ]),
      ),
    );
  }
}
