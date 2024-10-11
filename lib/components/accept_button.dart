import 'package:flutter/material.dart';

class AcceptButton extends StatelessWidget {
  AcceptButton({super.key, required this.isAccepted, required this.onTap, });
  final bool isAccepted;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color.fromRGBO(67, 101, 222, 1),
        ),
        child: Text(
          isAccepted ? "Đã được nhận" : "Chấp nhận",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
