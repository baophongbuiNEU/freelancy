
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/chat_bubble.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:freelancer/services/chat/chat_service.dart';


class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String avatar;
  final void Function()? onTap;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.avatar,
    required this.onTap,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

//for textfield focus
  FocusNode myFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    myFocus.addListener(() {
      if (myFocus.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocus.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  //send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // send the message
      await _chatService.sendMessageOld(
          widget.receiverID, _messageController.text);

      //clear the message
      _messageController.clear();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: GestureDetector(
          onTap: widget.onTap,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 10),
                width: 45,
                height: 45,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.avatar,
                  ),
                ),
              ),
              Text(
                widget.receiverEmail,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          //display the message
          Expanded(
            child: _buildMessageList(),
          ),

          //user input
          _buildUserInput()
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    int previousLength = 0;

    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error');
        }
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }
        // return listView
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // Check if the length of data has changed
            if (previousLength != snapshot.data!.docs.length) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn);
              }
              previousLength = snapshot.data!.docs.length;
            }

            return _buildMessageItem(doc);
          }).toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    //align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            isCurrentUser: isCurrentUser,
            message: data['message'],
          )
        ],
      ),
    );
  }

  // Widget _buildMessageList() {
  //   String senderID = _authService.getCurrentUser()!.uid;
  //   return FutureBuilder(
  //       future: _chatService.getChats(widget.receiverID, senderID),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasError) {
  //           return Text('Error: ${snapshot.error}');
  //         }
  //         //loading
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return Text('Loading...');
  //         }
  //         // return listView
  //         return ListView(
  //           controller: _scrollController,
  //           children:
  //               snapshot.data!.map((doc) => _buildMessageItem(doc)).toList(),
  //         );
  //       });
  // }

  // //build message item
  // Widget _buildMessageItem(ChatEntity doc) {
  //   // Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  //   //is current user
  //   bool isCurrentUser = doc.sender == _authService.getCurrentUser()!.uid;
  //   //align message to the right if sender is the current user, otherwise left
  //   var alignment =
  //       isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

  //   return Container(
  //     alignment: alignment,
  //     child: Column(
  //       crossAxisAlignment:
  //           isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  //       children: [
  //         ChatBubble(isCurrentUser: isCurrentUser, message: doc.message)
  //       ],
  //     ),
  //   );
  // }

  //build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, bottom: 15, right: 25, top: 15),
      child: Row(
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(1300),
                border: Border.all(
                    color: Color.fromRGBO(67, 101, 222, 1), width: 2)),
            padding:
                const EdgeInsets.only(left: 8, top: 5, bottom: 5, right: 8),
            child: TextField(
              keyboardType: TextInputType.multiline,
              controller: _messageController,
              style: const TextStyle(),
              focusNode: myFocus,
              decoration: InputDecoration(
                  hintText: "Viết tin nhắn tại đây",
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.normal,
                      fontSize: 17)),
            ),
          )),

          //send button
          Container(
            margin: EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color.fromRGBO(67, 101, 222, 1)),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
