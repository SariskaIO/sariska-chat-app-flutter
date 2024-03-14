import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sariska_chat_app_flutter/pages/chat_window.dart';
import '../model/room_model.dart';

class ChatController extends GetxController {
  TextEditingController roomName = TextEditingController();
  TextEditingController displayName = TextEditingController();

  TextEditingController typedMessage = TextEditingController();
  TextEditingController typedEmail = TextEditingController();
  TextEditingController typedGroupName = TextEditingController();

  late String userName;
  Rooms rooms = Rooms(rooms: []);

  Future<void> fetchRooms(String email, String userName, var token) async {
    print("Fetch room: ");
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

      rooms.rooms.clear();
      if (result["rooms"] != null) {
        rooms.rooms = List<Room>.from(
            result["rooms"].map((roomJson) => Room.fromJson(roomJson)));
      }
    } catch (error) {
      print('Error fetching rooms: $error');
    }
  }

  Future<void> searchUserEmail(
    String userName,
    String searchEmail,
    BuildContext context,
    var token,
    String userEmail,
  ) async {
    print("Inside Search User Email Func");
    try {
      String apiUrl =
          'http://api.dev.sariska.io/api/v1/messaging/users/verify?search_term=$searchEmail';

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

        print("Email:  ${userData['email']}");

        List<String> memberEmails = [];
        memberEmails.add(userData['id']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatInbox(
              roomName: roomName,
              userName: userName,
              isGroup: false,
              email: userEmail,
              token: token,
              memberEmails: memberEmails,
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
    }
  }

  String _generateRoomName(String userName1, String userName2) {
    var sortedUsernames = [userName1, userName2]..sort();
    return sortedUsernames.join('+');
  }

  Future<String> fetchToken(String? userName, String email) async {
    print("Chat fetch token Controller:");
    print("Email $email");
    print("Username $userName");
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

  Future<void> addGroupMembers(String userName, String email,
      List<String>? memberEmails, String roomName, var token) async {
    try {
      for (var i = 0; i < memberEmails!.length; i++) {
        String apiUrl =
            'http://api.dev.sariska.io/api/v1/messaging/rooms/$roomName/users/${memberEmails[i]}';
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        var data = json.decode(response.body);
        print("Add Group Members: ");
        print(data);
        print(response.body);
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Member with email ${memberEmails[i]} added successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (error) {
      print('Error adding group members: $error');
    }
  }
}
