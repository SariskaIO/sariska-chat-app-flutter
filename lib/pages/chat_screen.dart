import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import 'chat_inbox.dart';
import '../components/expandable_floating_button.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatController chatController = Get.put(ChatController());
  int currentPage = 1;

  // @override
  // void initState() {
  //   chatController.FetchRooms("dummyUserName");
  //   super.initState();
  // }

  static const _actionTitles = ['Create Group', 'Start Chat', 'Join Group'];

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
                            builder: (context) => const ChatInbox(
                              roomName: "saso",
                              userName: "gaurav",
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
                  height: 300,
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

                // for (String email in memberEmails) {
                //   groupService.addMemberToGroup(groupName, email.trim());
                // }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatInbox(
                      roomName: groupName,
                      userName: "shiva",
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
                      decoration: const InputDecoration(
                        hintText: "Enter email",
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
