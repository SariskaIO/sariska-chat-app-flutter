import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import 'chat_inbox.dart';
import 'expandable_floating_button.dart';
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

  static const _actionTitles = ['Create Group', 'Join Inbox', 'Join Group'];

  void _showAction(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(_actionTitles[index]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text("Chats"),
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  currentPage++;
                  // chatController.FetchRooms("dummyUserName", currentPage);
                }
                return true;
              },
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChatInbox(roomName: "baka"),
                            ),
                          );
                        },
                        leading: const CircleAvatar(
                          backgroundColor: Colors.greenAccent,
                          child: Text("G"),
                        ),
                        title: const Text("Room Name/Display Name"),
                        subtitle: const Text("user ids /latest message "),
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
            ),
          )
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () => _showAction(context, 0),
            icon: const Icon(Icons.format_size),
          ),
          ActionButton(
            onPressed: () => _showAction(context, 1),
            icon: const Icon(Icons.insert_photo),
          ),
        ],
      ),
    );
  }
}
