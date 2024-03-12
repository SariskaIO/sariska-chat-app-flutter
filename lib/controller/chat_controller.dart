import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:sariska_chat_app_flutter/model/chat_model.dart';
import 'package:sariska_chat_app_flutter/pages/chat_inbox.dart';

class ChatController extends GetxController {
  TextEditingController roomName = TextEditingController();
  TextEditingController displayName = TextEditingController();

  TextEditingController typedMessage = TextEditingController();
  TextEditingController typedEmail = TextEditingController();
  TextEditingController typedGroupName = TextEditingController();

  late String userName;
  var rooms = [].obs;

  List<Message> messages = <Message>[].obs;

  fetchRooms(String userName, String pageSize) async {
    var token = fetchToken();
    var url =
        "https://api.sariska.io/api/v2/rooms/?token=$token/?userName=$userName/?pageSize=$pageSize";
    var data = await http.get(Uri.parse(url));
    var result = jsonDecode(data.body);
    rooms = result["rooms"];
  }

  Future<void> searchUserEmail(String userName, BuildContext context) async {
    var token = await fetchToken();
    var url =
        "https://api.sariska.io/api/v2/rooms/?token=$token&userName=$userName";
    var data = await http.post(
      Uri.parse(url),
      body: {
        "email": typedEmail.text,
      },
    );

    // Future<void> fetchMessage(String userName, String roomName) async {
    //   var token = await fetchToken();
    //   var url =
    //       "https://api.sariska.io/api/v1/rooms/?token=$token&userName=$userName";
    //   var data = await http.post(Uri.parse(url), body: {
    //     "email": typedEmail.text,
    //   });
    // }

    var result = jsonDecode(data.body);
    bool isExist = result["is_exist"] as bool;

    if (isExist) {
      var otherUserName = "rakshas";
      var roomName = _generateRoomName(userName, otherUserName);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatInbox(
            roomName: roomName,
            userName: userName,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "User does not exist",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  String _generateRoomName(String userName1, String userName2) {
    var sortedUsernames = [userName1, userName2]..sort();
    return sortedUsernames.join(',');
  }

  late PhoenixChannel _channel;

  connectSocket(String roomName, String userName) async {
    var token = await fetchToken();
    final options = PhoenixSocketOptions(params: {"token": token});
    final socket = PhoenixSocket(
      "wss://api.sariska.io/api/v1/messaging/websocket",
      socketOptions: options,
    );
    await socket.connect();
    _channel = socket.channel("chat:$roomName");
    _channel.on("new_message", takeMessage);
    _channel.join();
    this.userName = userName;
  }

  Future<String> fetchToken() async {
    final body = jsonEncode({
      'apiKey': "{api-key}",
    });
    var url = 'https://api.sariska.io/api/v1/misc/generate-token';
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      return body['token'];
    } else {
      throw Exception('Failed to load album');
    }
  }

  takeMessage(payload, ref, joinRef) {
    messages.add(
      Message(
          message: payload["content"],
          isSender: payload["created_by_name"] == userName ? false : true,
          timestamp: DateTime.now(),
          userName: payload["created_by_name"]),
    );
  }

  sendMessage() async {
    _channel.push(event: "new_message", payload: {
      "content": typedMessage.text,
      "created_by_name": userName,
    });
    typedMessage.clear();
  }
}
