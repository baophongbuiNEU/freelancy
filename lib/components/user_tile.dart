import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String userName;
  final String avatar;
  final void Function()? onTap;
  final void Function()? onPressed;
  final String email;

  const UserTile({
    super.key,
    required this.onTap,
    required this.userName,
    required this.avatar,
    required this.email,
    required this.onPressed,
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
            Expanded(
              flex: 0,
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    avatar,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            // Spacer(),
            Expanded(
              flex: 0,
              child: IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    Icons.chat,
                    color: Color.fromRGBO(67, 101, 222, 1),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
