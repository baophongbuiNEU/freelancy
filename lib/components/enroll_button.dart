import 'package:flutter/material.dart';

class EnrollButton extends StatelessWidget {
  EnrollButton({super.key, required this.isEnrolled, required this.onTap});
  final bool isEnrolled;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        decoration: BoxDecoration(
            color: Color.fromRGBO(67, 101, 222, 1),
            borderRadius: BorderRadius.circular(5)),
        child: Text(
          isEnrolled ? "Rút đơn ứng tuyển" : "Ứng tuyển ngay",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
    );
  }
}
