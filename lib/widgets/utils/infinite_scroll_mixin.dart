import 'package:flutter/material.dart';

mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = false;
  String? cursorId;

  initializeScrollController(
      ScrollController controller, Future<void> Function() fetchData) {
    controller.addListener(() async {
      if (controller.position.pixels == controller.position.maxScrollExtent &&
          !isLoading) {
        setState(() {
          isLoading = true;
        });
        await fetchData();
        // 딜레이를 통해서 확인 하기
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
