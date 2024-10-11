class TopicItem {
  String name;
  String count;

  TopicItem({
    required this.name,
    required this.count,
  });

  factory TopicItem.fromData(String topicName, String topicCount) {
    return TopicItem(
      name: topicName,
      count: topicCount,
    );
  }
}
