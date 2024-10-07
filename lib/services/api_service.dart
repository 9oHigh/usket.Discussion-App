import 'dart:convert';

import 'package:app_team1/model/room.dart';
import 'package:app_team1/model/topic.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../model/player.dart';
import 'end_point/end_point.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000";

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

  Future<List<Room>> getRoomList(int limit,
      {String? cursorId, int? topicId}) async {
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
      List<Room> roomList = rooms.map((json) => Room.fromMap(json)).toList();
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('${response.statusCode}, ${response.body}');
      return false;
    }
  }
  
}
