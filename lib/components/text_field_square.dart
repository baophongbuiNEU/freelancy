import 'package:flutter/material.dart';

class TextFieldSquare extends StatelessWidget {
  final String title;
  final String content;
  final bool obscureText;
  final IconData iconData;
  final TextInputType keyboardType;
  final TextEditingController controller;
  const TextFieldSquare(
      {super.key,
      required this.content,
      required this.obscureText,
      required this.controller,
      required this.iconData,
      required this.title,
      required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17)),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 1.5)),
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 8),
          child: TextField(
            keyboardType: keyboardType,
            obscureText: obscureText,
            controller: controller,
            style: const TextStyle(),
            decoration: InputDecoration(
                hintText: content,
                alignLabelWithHint: true,
                prefixIcon: Icon(
                  iconData,
                  color: Colors.grey.shade600,
                ),
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                    fontSize: 17)),
          ),
        ),
      ],
    );
  }
}
