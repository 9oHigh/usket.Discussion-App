import 'package:app_team1/router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppTeam1());
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
