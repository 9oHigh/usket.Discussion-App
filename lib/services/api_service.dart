import 'dart:convert';
import 'package:app_team1/manager/topic_manager.dart';
import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic/topic.dart';
import 'package:app_team1/model/topic/topic_count.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../model/player.dart';
import 'end_point.dart';

class ApiService {
  // Emulator - 10.0.2.2:3000
  // Device - ipconfig에서 ip 주소 넣어서 사용 ex) http://127.168.0.23:3000
  final String _baseUrl = "http://192.168.0.16:3000";

  Future<List<TopicCount>> getTopicRoomCounts() async {
    final response =
        await http.get(Uri.parse("$_baseUrl${EndPoint.topicRoomCount.url}"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<TopicCount> topicCounts =
          data.map((json) => TopicCount.fromJson(json)).toList();
      return topicCounts;
    } else {
      throw Exception('Failed to load topic room counts');
    }
  }

  Future<List<Topic>> getTopicList() async {
    final response =
        await http.get(Uri.parse("$_baseUrl${EndPoint.topicList.url}"));

    if (200 <= response.statusCode && response.statusCode < 299) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Topic> topicList =
          jsonList.map((json) => Topic.fromMap(json)).toList();
      return topicList;
    } else {
      throw Exception();
    }
  }

  Future<List<Room>> getRoomList(String? cursorId, int limit) async {
    final int? selectedTopicId = TopicManager().getTopicId;
    final response = await http.post(
      Uri.parse("$_baseUrl${EndPoint.roomList.url}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'limit': limit,
        'cursorId': cursorId,
        'topicId': selectedTopicId,
      }),
    );

    if (200 <= response.statusCode && response.statusCode < 299) {
      Map<String, dynamic> jsonMap = jsonDecode(response.body);
      List<dynamic> rooms = jsonMap['rooms'];
      List<Room> roomList = await Future.wait(
        rooms.map((json) => Room.fromMap(json)).toList(),
      );
      if (selectedTopicId != null) {
        return roomList
            .where((room) => room.topicId == selectedTopicId)
            .toList();
      } else {
        return roomList;
      }
    } else {
      throw Exception("Failed to load room list");
    }
  }

  Future<Player?> getOrCreatePlayer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUuid = prefs.getString("uuid");

    if (savedUuid == null) {
      var uuid = const Uuid().v4();
      prefs.setString("uuid", uuid);
      savedUuid = uuid;
    }

    final response =
        await http.post(Uri.parse("$_baseUrl${EndPoint.player.url}"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'uuid': savedUuid,
            }));

    if (200 <= response.statusCode && response.statusCode < 299) {
      dynamic json = jsonDecode(response.body);
      return Player.fromJson(json);
    } else {
      return null;
    }
  }

  Future<Room?> createRoom(int topicId, String roomName, int playerId,
      DateTime startTime, DateTime endTime) async {
    final response = await http.post(
      Uri.parse("$_baseUrl${EndPoint.roomCreate.url}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          'topicId': topicId,
          'roomName': roomName,
          'playerId': playerId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        },
      ),
    );

    if (200 <= response.statusCode && response.statusCode < 299) {
      dynamic json = jsonDecode(response.body);
      return Room.fromCreated(json);
    } else {
      return null;
    }
  }

  Future<bool> deleteRoom(int roomId) async {
    final response = await http.delete(
      Uri.parse("$_baseUrl${EndPoint.deleteRoom.url}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          'roomId': roomId,
        },
      ),
    );

    if (200 <= response.statusCode && response.statusCode < 299) {
      return true;
    } else {
      return false;
    }
  }
}
