import 'package:shared_preferences/shared_preferences.dart';

class TopicManager {
  static final TopicManager _instance = TopicManager._internal();

  factory TopicManager() {
    return _instance;
  }

  TopicManager._internal();

  int? topicId;

  setTopicId(int? filteredTopicId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (filteredTopicId != null) {
      prefs.setInt("selectedTopic", filteredTopicId);
    } else {
      prefs.remove("selectedTopic");
    }
    topicId = filteredTopicId;
  }

  int? get getTopicId {
    return topicId;
  }
}
