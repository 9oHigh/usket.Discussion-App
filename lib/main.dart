import 'package:app_team1/manager/notification_manager.dart';
import 'package:app_team1/manager/socket_manager.dart';
import 'package:app_team1/manager/topic_manager.dart';
import 'package:app_team1/model/player.dart';
import 'package:app_team1/router.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'gen/fonts.gen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await _initializeUser();
  await _initializeTopicManager();
  await _initializeSocketManager();
  await _initializeNotificationManager();
  runApp(const AppTeam1());
}

_initializeUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Player? player = await ApiService().getOrCreatePlayer();
  if (player != null) {
    prefs.setInt("playerId", player.id);
  }
}

_initializeTopicManager() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int? selectedTopic = prefs.getInt("selectedTopic");
  TopicManager().setTopicId(selectedTopic);
}

_initializeSocketManager() async {
  await SocketManager().initSocket();
}

_initializeNotificationManager() async {
  await NotificationManager().initializeNotifications();
}

class AppTeam1 extends StatelessWidget {
  const AppTeam1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: FontFamily.pretendard,
      ),
      routerConfig: router,
    );
  }
}
