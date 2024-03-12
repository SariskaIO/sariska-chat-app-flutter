import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import 'chat_inbox.dart';
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
  ChatController chatController = Get.put(ChatController());
  int currentPage = 1;

  static const _actionTitles = ['Create Group', 'Start Chat', 'Join Group'];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    //chatController.FetchRooms("dummyUserName");
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshList();
    });
  }

  void _refreshList() {
    //chatController.FetchRooms("dummyUserName");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        shadowColor: Colors.black,
        backgroundColor: Colors.greenAccent,
        title: const Text("Sariska.io chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatInbox(
                              roomName: "saso",
                              userName: widget.username,
                            ),
                          ),
                        );
                      },
                      leading: const CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        child: Text("G"),
                      ),
                      title: index % 2 == 0
                          ? const Text("BTR Esports Group")
                          : const Text("Enies Lobby"),
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
            icon: const Icon(Icons.people),
          ),
          ActionButton(
            onPressed: () => _startInboxChat(context, 1),
            icon: const Icon(Icons.message_rounded),
          ),
        ],
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
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff2edf9),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: chatController.typedGroupName,
                            decoration: const InputDecoration(
                              hintText: "Enter group name",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xfff2edf9),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText:
                                  "Enter member's emails separated by commas",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
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
                List<String> memberEmails = emailController.text.split(',');

                // chatController.addGroupMembers(
                //     widget.username, widget.email, memberEmails);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatInbox(
                      roomName: groupName,
                      userName: widget.username,
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
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfff2edf9),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: chatController.typedEmail,
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
                        filled: true,
                        fillColor: Colors.greenAccent.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
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
                chatController.searchUserEmail("gaurav", context);
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
