enum EndPoint {
  topicList,
  topicRoomCount,
  player,
  roomList,
  roomCreate,
  roomIdList,
}

extension EndPointExtension on EndPoint {
  String get url {
    switch (this) {
      case EndPoint.topicList:
        return '/topic/list';
      case EndPoint.topicRoomCount:
        return '/topic/room-count';
      case EndPoint.player:
        return '/player';
      case EndPoint.roomList:
        return '/room/list';
      case EndPoint.roomCreate:
        return '/room/create';
      case EndPoint.roomIdList:
        return '/room/ids';
      default:
        return '';
    }
  }
}
