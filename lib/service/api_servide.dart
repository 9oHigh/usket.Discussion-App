import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/topic.dart';

enum EndPoint {
  topicList,
  topicRoomCount,
  player,
  roomList,
  roomCreate,
  roomIdList,
}

extension EndPointExtension on EndPoint {
  String get url {
    switch (this) {
      case EndPoint.topicList:
        return 'topic/list';
      case EndPoint.topicRoomCount:
        return '/topic/room-count';
      case EndPoint.player:
        return '/player';
      case EndPoint.roomList:
        return '/room/list';
      case EndPoint.roomCreate:
        return 'room/create';
      case EndPoint.roomIdList:
        return '/room/ids';
      default:
        return '';
    }
  }
}

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000/";

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
