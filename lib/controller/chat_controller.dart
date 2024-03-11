import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:sariska_chat_app_flutter/model/chat_model.dart';

class ChatController extends GetxController {
  TextEditingController roomName = TextEditingController();
  TextEditingController displayName = TextEditingController();
  TextEditingController typedMessage = TextEditingController();

  late String? userName;
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

  late PhoenixChannel _channel;

  connectSocket(String roomName) async {
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
        isSender: true,
        timestamp: DateTime.now(),
      ),
    );
  }

  sendMessage() async {
    _channel.push(event: "new_message", payload: {
      "content": typedMessage.text,
      "created_by_name": "gaurav",
    });
    messages.add(
      Message(
        message: typedMessage.text,
        isSender: true,
        timestamp: DateTime.now(),
      ),
    );
  }
}
