import 'package:flutter/material.dart';

class PasswordFieldComponent extends StatefulWidget {
  final String content;
  final IconData iconData;
  final TextEditingController controller;
  const PasswordFieldComponent(
      {super.key,
      required this.content,
      required this.controller,
      required this.iconData});

  @override
  State<PasswordFieldComponent> createState() => _PasswordFieldComponentState();
}

class _PasswordFieldComponentState extends State<PasswordFieldComponent> {
  bool obscureText = false;
  @override
  void initState() {
    obscureText = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.transparent)),
      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8, right: 8),
      child: TextField(
        obscureText: obscureText,
        controller: widget.controller,
        style: const TextStyle(),
        decoration: InputDecoration(
            hintText: widget.content,
            alignLabelWithHint: true,
            prefixIcon: Icon(
              widget.iconData,
              color: Colors.grey.shade600,
            ),
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                icon: obscureText
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off)),
            border: const OutlineInputBorder(borderSide: BorderSide.none),
            hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 17)),
      ),
    );
  }
}
