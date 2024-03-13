import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:sariska_chat_app_flutter/model/chat_model.dart';
import 'package:sariska_chat_app_flutter/pages/chat_window.dart';
import '../model/room_model.dart';

class ChatController extends GetxController {
  TextEditingController roomName = TextEditingController();
  TextEditingController displayName = TextEditingController();

  TextEditingController typedMessage = TextEditingController();
  TextEditingController typedEmail = TextEditingController();
  TextEditingController typedGroupName = TextEditingController();

  late String userName;

  late Rooms rooms = Rooms(rooms: []);

  Future<void> fetchRooms(String email, String userName, var token) async {
    try {
      var url =
          "http://api.dev.sariska.io/api/v1/messaging/rooms/fetch?email=$email";
      var data = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      var result = jsonDecode(data.body);
      print("Result");
      print(result);

      rooms.rooms =
          result["rooms"] != null ? List<String>.from(result["rooms"]) : [];
    } catch (error) {
      print('Error fetching rooms: $error');
    }
  }

  Future<void> searchUserEmail(
      String userName, String email, BuildContext context, var token) async {
    try {
      String apiUrl =
          'http://api.dev.sariska.io/api/v1/messaging/users/verify?search_term=$email';

      var data = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var result = jsonDecode(data.body);
      print("Result in func searchUserEmail ");
      print(result);
      bool isExist = result["exists"];
      Map<String, dynamic>? userData = result['user'];
      if (isExist) {
        var otherUserName = userData!['name'];
        var roomName = _generateRoomName(userName, otherUserName);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatInbox(
              roomName: roomName,
              userName: userName,
              isGroup: false,
              email: email,
              token: token,
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
        Navigator.pop(context);
      }
    } catch (error) {
      print('Error searching user email: $error');
      // Handle error here if needed
    }
  }

  String _generateRoomName(String userName1, String userName2) {
    var sortedUsernames = [userName1, userName2]..sort();
    return sortedUsernames.join('+');
  }

  late PhoenixChannel _channel;

  List<Message> messages = <Message>[].obs;

  connectSocket(String roomName, String userName, String email) async {
    var token = await fetchToken(userName, email);
    final options = PhoenixSocketOptions(params: {"token": token});
    final socket = PhoenixSocket(
      "wss://api.dev.sariska.io/api/v1/messaging/websocket",
      socketOptions: options,
    );
    await socket.connect();
    _channel = socket.channel("chat:$roomName");
    _channel.on("new_message", takeMessage);
    //_channel.on("archived_message", takeMessage);
    _channel.join();
    this.userName = userName;
  }

  Future<String> fetchToken(String userName, String email) async {
    try {
      final body = jsonEncode({
        'apiKey': "{api-key}",
        'user': {
          'id': email,
          'name': userName,
        }
      });
      var url = 'https://api.dev.sariska.io/api/v1/misc/generate-token';
      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"}, body: body);
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return body['token'];
      } else {
        throw Exception('Failed to fetch token');
      }
    } catch (error) {
      print('Error fetching token: $error');
      rethrow;
    }
  }

  takeMessage(payload, ref, joinRef) {
    final newMessage = Message(
      message: payload["content"],
      isSender: payload["created_by_name"] == userName ? false : true,
      timestamp: DateTime.parse(payload["inserted_at"]),
      userName: payload["created_by_name"],
    );
    int lastIndex = messages.length - 1;
    messages.insert(lastIndex + 1, newMessage);
    //messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    update();
  }

  sendMessage(List<Message> messages) async {
    _channel.push(event: "new_message", payload: {
      "content": typedMessage.text,
      "created_by_name": userName,
    });
    typedMessage.clear();
    update();
  }
}
