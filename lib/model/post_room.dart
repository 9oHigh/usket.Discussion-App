class PostRoom {
  int topicId;
  String roomName;
  int playerId;
  DateTime startTime;
  DateTime endTime;

  PostRoom({
    required this.topicId,
    required this.roomName,
    required this.playerId,
    required this.startTime,
    required this.endTime,
  });
}