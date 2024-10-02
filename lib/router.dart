import 'package:app_team1/widgets/page/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(initialLocation: "/home", routes: [
  GoRoute(
    path: "/home",
    pageBuilder: (context, state) => const CupertinoPage(child: HomePage()),
  ),

  /*
   GoRoute(
    path: "/filter",
    builder: (context, state) => const FilterScreen(),
  ),
  GoRoute(
    path: "/create_room",
    builder: (context, state) => const CreateRoomScreen(),
  ),
  GoRoute(
    path: "/chat",
    builder: (context, state) => const ChatScreen(),
  ),
  */
]);
