class Rooms {
  List<String>? rooms;

  Rooms({this.rooms});

  Rooms.fromJson(Map<String, dynamic> json) {
    rooms = json['rooms'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rooms'] = rooms;
    return data;
  }
}
