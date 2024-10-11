import 'dart:convert';

import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../model/player.dart';
import 'end_point/end_point.dart';

class ApiService {
  // Emulator - 10.0.2.2:3000
  // Device - ifconfig에서 en0에 있는 ip 주소 넣어서 사용 ex) http://127.168.0.23:3000
  final String baseUrl = "http://10.0.2.2:3000";

  Future<List<Map<String, dynamic>>> getTopicRoomCounts() async {
    final response = await http.get(Uri.parse("$baseUrl${EndPoint.topicRoomCount.url}"));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to load topic room counts');
    }
  }

  Future<List<Topic>> getTopicList() async {
    final response =
        await http.get(Uri.parse("$baseUrl${EndPoint.topicList.url}"));

    if (200 <= response.statusCode && response.statusCode < 299) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Topic> topicList =
          jsonList.map((json) => Topic.fromMap(json)).toList();
      return topicList;
    } else {
      throw Exception();
    }
  }

  Future<List<Room>> getRoomList(String? cursorId, int limit,
      {int? topicId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl${EndPoint.roomList.url}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'limit': limit,
        'cursorId': cursorId,
        'topicId': topicId,
      }),
    );

    if (200 <= response.statusCode && response.statusCode < 299) {
      Map<String, dynamic> jsonMap = jsonDecode(response.body);
      List<dynamic> rooms = jsonMap['rooms'];
      List<Room> roomList = await Future.wait(
        rooms.map((json) => Room.fromMap(json)).toList(),
      );
      return roomList;
    } else {
      throw Exception("Failed to load room list");
    }
  }

  Future<Player?> getOrCreatePlayer() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? savedUuid = pref.getString("uuid");

    if (savedUuid == null) {
      var uuid = const Uuid().v1();
      pref.setString("uuid", uuid);
      savedUuid = uuid;
    }

    final response =
        await http.post(Uri.parse("$baseUrl${EndPoint.player.url}"),
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

  Future<bool> createRoom(int topicId, String roomName, int playerId,
      DateTime startTime, DateTime endTime) async {
    final response = await http.post(
      Uri.parse("$baseUrl${EndPoint.roomCreate.url}"),
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
      return true;
    } else {
      return false;
    }
  }
}
