class Message {
  String message;
  bool isSender;
  DateTime timestamp;
  String userName;
  // MessageStatus status;


  Message({
    required this.message,
    required this.isSender,
    required this.timestamp,
    required this.userName,
    // required this.status,

  });
}
// enum MessageStatus {
//   sent,
//   delivered,
//   seen,
// }
