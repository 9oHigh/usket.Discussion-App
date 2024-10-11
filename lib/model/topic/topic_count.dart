class TopicCount {
  int id;
  String count;

  TopicCount({required this.id, required this.count});

  factory TopicCount.fromJson(Map<String, dynamic> map) {
    return TopicCount(
      id: map['id'],
      count: map['room_count'],
    );
  }
}
