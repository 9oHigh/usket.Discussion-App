import 'package:app_team1/screens/home_page.dart';
import 'package:app_team1/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'screens/create_room_screen.dart';
import 'screens/filter_screen.dart';

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
    GoRoute(
      path: "/chat/:roomId/:roomName/:endTime",
      pageBuilder: (context, state) {
        final roomId = state.pathParameters['roomId'] ?? '';
        final roomName = state.pathParameters['roomName'] ?? '';
        final endTimeString = state.pathParameters['endTime'] ?? '';
        final endTime = DateTime.tryParse(endTimeString) ?? DateTime.now();
        return CupertinoPage(
          child: ChatScreen(
            roomId: roomId,
            roomName: roomName,
            endTime: endTime,
          ),
        );
      },
    )
  ],
);
