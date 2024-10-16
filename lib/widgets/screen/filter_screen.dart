import 'package:app_team1/manager/toast_manager.dart';
import 'package:app_team1/manager/topic_manager.dart';
import 'package:app_team1/model/topic/topic_count.dart';
import 'package:app_team1/model/topic/topic_item.dart';
import 'package:app_team1/widgets/custom/widget/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../model/topic/topic.dart';
import '../../services/api_service.dart';
import '../custom/style/shadow_style.dart';
import '../utils/app_color.dart';
import '../utils/app_constant.dart';
import '../utils/app_font_size.dart';
import '../utils/topic_mapped.dart';

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
    _fetchTopicList().then((_) => _setSelectedTopic());
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
      backgroundColor: AppColor.backgroundColor,
      appBar: CustomAppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColor.appBarContentsColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: 'TOPIC SETTING',
        actions: [
          IconButton(
            onPressed: () {
              TopicManager().setTopicId(_selectedIndex != null
                  ? _topicList[_selectedIndex!].id
                  : null);
              context.pop(true);
            },
            icon: const Icon(
              Icons.check,
              color: AppColor.appBarContentsColor,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConstant.getScreenWidth(context) * 0.03),
        child: _topicList.isEmpty
            ? const Center(
                child: Text(
                  '주제를 불러오는 데 실패했습니다.',
                  style: TextStyle(color: Colors.black),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                  ),
                  itemCount: _topicList.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedIndex == index;
                    Color boxColor =
                        isSelected ? AppColor.thirdaryColor : Colors.white;
                    Color topicNameColor =
                        isSelected ? Colors.white : Colors.black;
                    Color badgeColor = isSelected ? Colors.white : Colors.blue;
                    Color badgeTextColor =
                        isSelected ? Colors.black : Colors.white;

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex =
                                  _selectedIndex == index ? null : index;
                            });
                          },
                          child: Container(
                            decoration: createShadowStyle(color: boxColor),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (isSelected
                                          ? topicImageMap[
                                                  '${_topicList[index].name}-selected']
                                              ?.image(
                                                  width: AppConstant
                                                      .filterImageSize(context),
                                                  height: AppConstant
                                                      .filterImageSize(context),
                                                  fit: BoxFit.cover)
                                          : topicImageMap[_topicList[
                                                      index]
                                                  .name]
                                              ?.image(
                                                  width: AppConstant
                                                      .filterImageSize(context),
                                                  height: AppConstant
                                                      .filterImageSize(context),
                                                  fit: BoxFit.cover)) ??
                                      Container(),
                                  Text(
                                    topicNameMap[_topicList[index].name] ??
                                        '기타',
                                    style: TextStyle(
                                      color: topicNameColor,
                                      fontSize: AppFontSize.filterTextSize,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            alignment: Alignment.center,
                            width: AppConstant.badgeSize(context),
                            height: AppConstant.badgeSize(context),
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
                  },
                ),
              ),
      ),
    );
  }
}
