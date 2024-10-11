import 'package:app_team1/model/player.dart';
import 'package:app_team1/router.dart';
import 'package:app_team1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await _initializeUser();
  runApp(const AppTeam1());
}

_initializeUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Player? player = await ApiService().getOrCreatePlayer();
  if (player != null) {
    prefs.setInt("playerId", player.id);
  }
}

class AppTeam1 extends StatelessWidget {
  const AppTeam1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
