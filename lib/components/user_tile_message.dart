import 'package:flutter/material.dart';

class UserTileMessage extends StatelessWidget {
  final String userName;
  final String avatar;
  final void Function()? onTap;
  final String lastMessage;
  final String sendTime;
  const UserTileMessage({
    super.key,
    required this.onTap,
    required this.userName,
    required this.avatar,
    required this.lastMessage,
    required this.sendTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            border:
                Border.all(color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  avatar,
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  lastMessage,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            Spacer(),
            Text(sendTime),
          ],
        ),
      ),
    );
  }
}
