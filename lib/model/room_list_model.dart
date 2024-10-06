class RoomListModel {
  String topicName;
  String roomName;
  DateTime startTime;
  DateTime endTime;
  bool isReserved = false;

  RoomListModel({
    required this.topicName,
    required this.roomName,
    required this.startTime,
    required this.endTime,
  });

  // MARK: - factory.fromMap
}
