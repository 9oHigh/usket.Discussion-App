import 'package:app_team1/widgets/page/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'widgets/screen/create_room_screen.dart';
import 'widgets/screen/filter_screen.dart';

const HomePage homePage = HomePage();

final GoRouter router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(
      path: "/home",
      pageBuilder: (context, state) => const CupertinoPage(child: homePage),
    ),
    GoRoute(
      path: "/filter",
      pageBuilder: (context, state) =>
          const CupertinoPage(child: FilterScreen()),
    ),
    GoRoute(
      path: "/create_room",
      pageBuilder: (context, state) =>
          const CupertinoPage(child: CreateRoomScreen()),
    ),
  ],
);
