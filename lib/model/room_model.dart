class Room {
  final String? mostRecentMessage;
  final int roomId;
  final String sessionId;

  Room({
    this.mostRecentMessage,
    required this.roomId,
    required this.sessionId,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      mostRecentMessage: json['most_recent_message'],
      roomId: json['room_id'],
      sessionId: json['session_id'] ?? "temp",
    );
  }
}

class Rooms {
  List<Room> rooms;

  Rooms({required this.rooms});
}

class RoomsResponse {
  final List<Room> rooms;

  RoomsResponse({
    required this.rooms,
  });

  factory RoomsResponse.fromJson(Map<String, dynamic> json) {
    var roomList = json['rooms'] as List;
    List<Room> rooms =
        roomList.map((roomJson) => Room.fromJson(roomJson)).toList();

    return RoomsResponse(
      rooms: rooms,
    );
  }
}
