import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:sariska_chat_app_flutter/components/app_colors.dart';
import 'package:sariska_chat_app_flutter/model/chat_model.dart';
import 'package:http/http.dart' as http;

class ChatInbox extends StatefulWidget {
  ChatInbox({
    super.key,
    required this.roomName,
    required this.userName,
    required this.isGroup,
    required this.email,
    required this.token,
  });
  final String roomName;
  final String userName;
  final bool isGroup;
  final String email;
  var token;

  @override
  State<ChatInbox> createState() => _ChatInboxState();
}

class _ChatInboxState extends State<ChatInbox> {
  @override
  void initState() {
    connectSocket(
      widget.roomName,
      widget.userName,
      widget.email,
    );
    super.initState();
  }

  late PhoenixChannel _channel;
  TextEditingController typedMessage = TextEditingController();
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
    _channel.on("archived_message", takeArchivedMessage);
    _channel.join();
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

  takeArchivedMessage(payload, ref, joinRef) {
    print("Iam archived");
    final newMessage = Message(
      message: payload["content"],
      isSender: payload["created_by_name"] == widget.userName ? false : true,
      timestamp: DateTime.parse(payload["inserted_at"]),
      userName: payload["created_by_name"],
    );
    messages.add(newMessage);
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  takeMessage(payload, ref, joinRef) {
    final newMessage = Message(
      message: payload["content"],
      isSender: payload["created_by_name"] == widget.userName ? false : true,
      timestamp: DateTime.parse(payload["inserted_at"]),
      userName: payload["created_by_name"],
    );
    messages.add(newMessage);

    //messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  sendMessage() async {
    _channel.push(event: "new_message", payload: {
      "content": typedMessage.text,
      "created_by_name": widget.userName,
    });
    typedMessage.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        messages.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.colorPrimary,
          title: Text(widget.roomName),
          actions: [
            widget.isGroup
                ? IconButton(
                    onPressed: () {
                      TextEditingController emailController =
                          TextEditingController();
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Add new Members",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: emailController,
                                          decoration: InputDecoration(
                                            labelText:
                                                'email(s),separated by ","',
                                            filled: true,
                                            fillColor: AppColors.colorPrimary
                                                .withOpacity(0.3),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // List<String> memberEmails = emailController.text.split(',');
                                  // chatController.addGroupMembers(
                                  //     widget.username, widget.email, memberEmails);

                                  Navigator.pop(context);
                                },
                                child: const Text('Add member'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(IconlyLight.addUser),
                  )
                : const Text("")
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(25),
          height: 900,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              Obx(
                () => Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      key: Key(messages.length.toString()),
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: messages[index].isSender
                              ? Alignment.topLeft
                              : Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: messages[index].isSender
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 2,
                                  ),
                                  child: Text(
                                    DateFormat.Hm()
                                        .format(messages[index].timestamp),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: messages[index].isSender
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.colorSecondary,
                                      child: Text(
                                        messages[index]
                                            .userName
                                            .substring(0, 1),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: messages[index].isSender
                                              ? const Radius.circular(8)
                                              : const Radius.circular(10),
                                          bottomRight: messages[index].isSender
                                              ? const Radius.circular(10)
                                              : const Radius.circular(8),
                                          bottomLeft: const Radius.circular(8),
                                          topLeft: const Radius.circular(8),
                                        ),
                                        color: messages[index].isSender
                                            ? AppColors.colorSecondary
                                            : AppColors.colorSecondary,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          messages[index].message,
                                          style: TextStyle(
                                            color: messages[index].isSender
                                                ? Colors.white
                                                : Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff2edf9),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ThemeData().colorScheme.copyWith(
                            primary: AppColors.colorPrimary,
                          ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextField(
                        controller: typedMessage,
                        decoration: InputDecoration(
                          hintText: "Type message...",
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (typedMessage.text.isNotEmpty) {
                                sendMessage();
                                setState(() {
                                  messages.sort((a, b) =>
                                      a.timestamp.compareTo(b.timestamp));
                                });
                              } else {
                                Fluttertoast.showToast(
                                  msg: "Please enter user name",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            },
                            icon: const Icon(Icons.send),
                            color: AppColors.colorPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
