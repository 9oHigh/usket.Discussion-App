import 'package:flutter/material.dart';
import '../../model/room.dart';

mixin InfiniteScrollMixin<T, W extends StatefulWidget> on State<W> {
  List<T> roomList = [];
  bool isLoading = false;
  String? cursorId; // 페이징을 위한 커서 ID

  void initializeScrollController(
      ScrollController controller, Future<List<T>> Function() fetchData) {
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent &&
          !isLoading) {
        loadMoreData(fetchData);
      }
    });
  }

  Future<void> loadMoreData(Future<List<T>> Function() fetchData) async {
  setState(() {
    if (isLoading) return; // 이미 로딩 중이면 종료
    isLoading = true; // 로딩 시작
  });

  final newRooms = await fetchData(); // 데이터 로드
  setState(() {
    roomList.addAll(newRooms); // 새로운 룸들 추가
    if (newRooms.isNotEmpty) {
      cursorId = getRoomId(newRooms.last); // 커서 ID 업데이트
      print('새로운 방이 추가됨');
    } else {
      cursorId = null; // 더 이상 데이터 없음
    }
    isLoading = false; // 로딩 종료
  });
}

  // ID를 추출하는 메서드 정의
  String getRoomId(T room) {
    if (room is Room) {
      return room.roomId.toString(); // Room 클래스의 ID를 문자열로 반환
    }
    throw Exception('Unsupported type: ${room.runtimeType}'); // 타입이 지원되지 않을 경우 예외 발생
  }
}