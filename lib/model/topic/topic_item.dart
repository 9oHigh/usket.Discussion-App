class TopicItem {
  int id;
  String name;
  String count;

  TopicItem({
    required this.id,
    required this.name,
    required this.count,
  });

  factory TopicItem.fromData(int id, String topicName, String topicCount) {
    return TopicItem(
      id: id,
      name: topicName,
      count: topicCount,
    );
  }
}
