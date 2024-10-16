class Player {
  int id;
  String uuid;

  Player({
    required this.id,
    required this.uuid,
  });

  factory Player.fromJson(Map<String, dynamic> map) {
    return Player(id: map['id'], uuid: map['uuid']);
  }
}