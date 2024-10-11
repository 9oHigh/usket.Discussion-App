import 'package:app_team1/manager/toast_manager.dart';
import 'package:app_team1/manager/topic_manager.dart';
import 'package:app_team1/model/topic/topic_count.dart';
import 'package:app_team1/model/topic/topic_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:go_router/go_router.dart';
import '../../model/topic/topic.dart';
import '../../services/api_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final ApiService _apiService = ApiService();
  List<TopicItem> _topicList = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _fetchTopicList().then((_) {
      _setSelectedTopic();
    });
  }

  Future<void> _fetchTopicList() async {
    try {
      List<Topic> topicList = await _apiService.getTopicList();
      List<TopicCount> topicCounts = await _apiService.getTopicRoomCounts();
      Map<int, String> topicCountMap = {
        for (var count in topicCounts) count.id: count.count
      };
      List<TopicItem> topicItemList = topicList.map((topic) {
        String count = topicCountMap[topic.id] ?? "0";
        return TopicItem.fromData(topic.id, topic.name, count);
      }).toList();

      setState(() {
        _topicList = topicItemList;
      });
    } catch (e) {
      ToastManager().showToast(context, "토픽들을 가져오지 못했어요.\n다시 시도해주세요.");
    }
  }

  Future<void> _setSelectedTopic() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? topicId = prefs.getInt("selectedTopic");
    final int selectedIndex =
        _topicList.indexWhere((topic) => topic.id == topicId);
    if (selectedIndex != -1) {
      setState(() {
        _selectedIndex = selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Align(
          alignment: Alignment.center,
          child: Text('토픽 설정'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_selectedIndex != null) {
                TopicManager().setTopicId(_topicList[_selectedIndex!].id);
              } else {
                ToastManager().showToast(context, "토픽을 선택해주세요!");
              }
              context.pop(true);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 20, 30),
        child: _topicList.isEmpty
            ? const Center(
                child: Text(
                  '주제를 불러오는 데 실패했습니다.',
                  style: TextStyle(color: Colors.black),
                ),
              )
            : Wrap(
                alignment: WrapAlignment.start,
                spacing: 12.0,
                runSpacing: 12.0,
                children: List.generate(_topicList.length, (index) {
                  bool isSelected = _selectedIndex == index;
                  Color boxColor = isSelected ? Colors.blue : Colors.blue[50]!;
                  Color badgeColor = isSelected ? Colors.white : Colors.blue;
                  Color badgeTextColor =
                      isSelected ? Colors.black : Colors.white;
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedIndex != null &&
                                _selectedIndex == index) {
                              _selectedIndex = null;
                            } else {
                              _selectedIndex = index;
                            }
                          });
                        },
                        child: Container(
                          width: AppConstants.topicBoxSize(context),
                          height: AppConstants.topicBoxSize(context),
                          decoration: BoxDecoration(
                            color: boxColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _topicList[index].name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
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
                            color: badgeColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _topicList[index].count,
                            style: TextStyle(
                              color: badgeTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
      ),
    );
  }
}
