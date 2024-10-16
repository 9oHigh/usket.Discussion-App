import 'package:flutter/material.dart';

mixin InfiniteScrollMixin<T extends StatefulWidget> on State<T> {
  bool isLoading = false;
  String? cursorId;

  initializeScrollController(
      ScrollController controller, Future<void> Function() fetchData) {
    controller.addListener(() async {
      if (controller.position.pixels == controller.position.maxScrollExtent &&
          !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        await fetchData();
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }
}
