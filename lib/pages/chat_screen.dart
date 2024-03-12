import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sariska_chat_app_flutter/components/app_colors.dart';
import '../controller/chat_controller.dart';
import 'chat_window.dart';
import '../components/expandable_floating_button.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.username,
    required this.email,
  });

  final String username;
  final String email;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int currentPage = 1;

  static const _actionTitles = ['Create Group', 'Start Chat', 'Join Group'];

  Timer? _timer;

  late ChatController chatController;

  @override
  void initState() {
    super.initState();
    chatController = Get.put(ChatController());
    chatController.fetchRooms(widget.username, widget.email);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _refreshList();
    });
  }

  void _refreshList() {
    chatController.fetchRooms(widget.username, widget.email);
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
                                roomName: chatController.rooms.rooms![index],
                                userName: widget.username,
                                isGroup: true,
                                email: widget.email,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: AppColors.colorPrimary,
                          child: Text(
                            chatController.rooms.rooms![index].substring(0, 1),
                          ),
                        ),
                        title: Text(chatController.rooms.rooms![index]),
                        subtitle: Text(
                          "hi there, wassup 👋",
                          style: TextStyle(
                              fontWeight: index % 2 == 0
                                  ? FontWeight.bold
                                  : FontWeight.w100),
                        ),
                        trailing: Text(
                            DateFormat.Hm().format(DateTime.now()).toString()),
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
              onPressed: () {
                String groupName = chatController.typedGroupName.text;
                // List<String> memberEmails = emailController.text.split(',');
                // chatController.addGroupMembers(
                //     widget.username, widget.email, memberEmails);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatInbox(
                      roomName: groupName,
                      userName: widget.username,
                      isGroup: true,
                      email: widget.email,
                    ),
                  ),
                );
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
                  "gaurav",
                  widget.email,
                  context,
                );
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
