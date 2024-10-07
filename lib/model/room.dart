class Room {
  int roomId;
  int topicId;
  int playerId;
  String roomName;
  DateTime startTime;
  DateTime endTime;
  bool isReserved = false;

  Room({
    required this.roomId,
    required this.topicId,
    required this.playerId,
    required this.roomName,
    required this.startTime,
    required this.endTime,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      roomId: map['id'],
      playerId: map['player_id'],
      topicId: map['topic_id'],
      roomName: map['name'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
    );
  }
}
