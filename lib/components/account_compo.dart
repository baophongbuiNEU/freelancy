import 'package:flutter/material.dart';

class AccountCompo extends StatelessWidget {
  final String name;
  final IconData icon;
  final Function()? onTap;

  const AccountCompo(
      {super.key, required this.name, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        height: 70,
        child: Row(
          children: [
            Icon(
              icon,
              size: 27,
              color: Color.fromRGBO(67, 101, 222, 1),
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              name,
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 27,
              color: Color.fromRGBO(67, 101, 222, 1),
            ),
          ],
        ),
      ),
    );
  }
}
