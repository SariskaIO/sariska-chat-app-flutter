import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sariska_chat_app_flutter/controller/chat_controller.dart';

class ChatInbox extends StatefulWidget {
  const ChatInbox({super.key, required this.roomName});

  final String roomName;
  @override
  State<ChatInbox> createState() => _ChatInboxState();
}

class _ChatInboxState extends State<ChatInbox> {
  late ChatController chatController;

  @override
  void initState() {
    chatController = Get.find();
    chatController.connectSocket(widget.roomName);
    // chatController.FetchRooms("dummyUserName");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text("Room Name: ${widget.roomName}"),
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
                    // controller: lobbyPageController.scrollController,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: chatController.messages.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: chatController.messages[index].isSender
                            ? Alignment.topLeft
                            : Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment:
                                chatController.messages[index].isSender
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 2,
                                ),
                                child: Text(
                                  DateFormat.Hm().format(
                                      chatController.messages[index].timestamp),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: !chatController
                                          .messages[index].isSender
                                      ? const BorderRadius.only(
                                          topRight: Radius.circular(6),
                                          bottomRight: Radius.circular(6),
                                          bottomLeft: Radius.circular(6),
                                          topLeft: Radius.circular(6),
                                        )
                                      : const BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(8),
                                          topLeft: Radius.elliptical(-80, 1),
                                        ),
                                  color: chatController.messages[index].isSender
                                      ? Colors.green
                                      : Colors.greenAccent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    chatController.messages[index].message,
                                    style: TextStyle(
                                      color: chatController
                                              .messages[index].isSender
                                          ? Colors.greenAccent.withOpacity(0.3)
                                          : Colors.white,
                                      fontSize: 16,
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
                          primary: Colors.greenAccent,
                        ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: chatController.typedMessage,
                      decoration: InputDecoration(
                        hintText: "Type message...",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () {
                            chatController.sendMessage();
                          },
                          icon: const Icon(Icons.send),
                          color: Colors.greenAccent,
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
    );
  }
}
