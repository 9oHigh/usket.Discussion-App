import 'package:shared_preferences/shared_preferences.dart';

class TopicManager {
  static final TopicManager _instance = TopicManager._internal();

  factory TopicManager() {
    return _instance;
  }

  TopicManager._internal();

  int? topicId;

  setTopicId(int? filteredTopicId) async {
    if (filteredTopicId != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("selectedTopic", filteredTopicId);
    }
    topicId = filteredTopicId;
  }

  int? get getTopicId {
    return topicId;
  }
}
