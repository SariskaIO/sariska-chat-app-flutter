class Message {
  String message;
  bool isSender;
  DateTime timestamp;
  String userName;

  Message({
    required this.message,
    required this.isSender,
    required this.timestamp,
    required this.userName,
  });
}
