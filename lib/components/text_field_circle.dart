import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  final String content;
  final bool obscureText;
  final IconData iconData;
  final TextInputType keyboardType;
  final TextEditingController controller;
  const TextFieldComponent(
      {super.key,
      required this.content,
      required this.obscureText,
      required this.controller,
      required this.iconData,
      required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.transparent)),
      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 8),
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
    );
  }
}
