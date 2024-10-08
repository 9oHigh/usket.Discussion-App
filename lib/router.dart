import 'package:app_team1/widgets/page/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'widgets/screen/create_room_screen.dart';

const HomePage homePage = HomePage();

final GoRouter router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(
      path: "/home",
      pageBuilder: (context, state) => const CupertinoPage(child: homePage),
    ),
    GoRoute(
      path: "/create_room",
      pageBuilder: (context, state) =>
          const CupertinoPage(child: CreateRoomScreen()),
    ),
  ],
);
