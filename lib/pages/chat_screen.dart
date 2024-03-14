import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sariska_chat_app_flutter/components/app_colors.dart';
import 'package:sariska_chat_app_flutter/model/room_model.dart';
import '../controller/chat_controller.dart';
import 'chat_window.dart';
import '../components/expandable_floating_button.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {super.key,
      required this.username,
      required this.email,
      required this.token});

  final String username;
  final String email;
  var token;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _actionTitles = ['Create Group', 'Start Chat'];
  Timer? _timer;
  late ChatController chatController;

  @override
  void initState() {
    super.initState();
    chatController = Get.put(ChatController());
    chatController.fetchRooms(
      widget.email,
      widget.username,
      widget.token,
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _refreshList();
    });
  }

  void _refreshList() {
    chatController.fetchRooms(
      widget.email,
      widget.username,
      widget.token,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Get.deleteAll();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          shadowColor: Colors.black,
          backgroundColor: AppColors.colorPrimary,
          title: const Text("Sariska.io chat"),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: chatController.rooms.rooms!.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatInbox(
                                roomName:
                                    chatController.rooms.rooms[index].sessionId,
                                userName: widget.username,
                                isGroup: !chatController
                                    .rooms.rooms[index].sessionId
                                    .contains("+"),
                                email: widget.email,
                                token: widget.token,
                                chatController: chatController,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: AppColors.colorPrimary,
                          child: Text(
                            chatController.rooms.rooms[index].sessionId
                                .substring(0, 1)
                                .toUpperCase(),
                          ),
                        ),
                        title:
                            Text(chatController.rooms.rooms[index].sessionId),
                        trailing: Text(
                          chatController.rooms.rooms[index].mostRecentMessage !=
                                  null
                              ? DateFormat.Hm().format(
                                  DateTime.parse(chatController.rooms
                                          .rooms[index].mostRecentMessage!)
                                      .toLocal(),
                                )
                              : '',
                        ),
                      ),
                      const Divider(
                        thickness: 0.3,
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
        floatingActionButton: ExpandableFab(
          distance: 112,
          children: [
            ActionButton(
              onPressed: () => _createGroup(context, 0),
              icon: const Icon(IconlyLight.user3),
            ),
            ActionButton(
              onPressed: () => _startInboxChat(context, 1),
              icon: const Icon(IconlyLight.message),
            ),
          ],
        ),
      ),
    );
  }

  void _createGroup(BuildContext context, int index) {
    TextEditingController emailController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: SizedBox(
                  child: Column(
                    children: [
                      Text(
                        _actionTitles[index],
                        style: const TextStyle(
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
                          controller: chatController.typedGroupName,
                          decoration: InputDecoration(
                            labelText: 'Enter Group Name',
                            filled: true,
                            fillColor: AppColors.colorPrimary.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
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
                            labelText: 'email(s),separated by ","',
                            filled: true,
                            fillColor: AppColors.colorPrimary.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String groupName = chatController.typedGroupName.text;
                List<String> memberEmails = emailController.text.split(',');
                if (groupName.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatInbox(
                        roomName: groupName,
                        userName: widget.username,
                        isGroup: true,
                        email: widget.email,
                        token: widget.token,
                        memberEmails: memberEmails,
                        chatController: chatController,
                      ),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Enter Group name",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              child: const Text('Create group'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _startInboxChat(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 130,
            child: Column(
              children: [
                Text(
                  _actionTitles[index],
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: chatController.typedEmail,
                    decoration: InputDecoration(
                      labelText: 'Enter User Email',
                      filled: true,
                      fillColor: AppColors.colorPrimary.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                chatController.searchUserEmail(
                    widget.username,
                    chatController.typedEmail.text,
                    context,
                    widget.token,
                    widget.email);
              },
              child: const Text('Start Chat'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
