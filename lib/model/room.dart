import 'package:shared_preferences/shared_preferences.dart';

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
    this.isReserved = false,
  });

  static Future<Room> fromMap(Map<String, dynamic> map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int roomId = map['id'];
    final bool isReserved = prefs.getBool('room_$roomId') ?? false;

    return Room(
      roomId: roomId,
      playerId: map['player_id'],
      topicId: map['topic_id'],
      roomName: map['name'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      isReserved: isReserved,
    );
  }

  Future<void> saveIsReserved(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isReserved = value;
    await prefs.setBool('room_$roomId', value);
  }
}
