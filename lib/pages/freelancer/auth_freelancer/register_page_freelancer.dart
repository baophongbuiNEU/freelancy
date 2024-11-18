// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/my_button.dart';
import 'package:freelancer/components/password_field.dart';
import 'package:freelancer/components/text_field_circle.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/home_page_freelancer.dart';
import 'package:freelancer/services/auth/auth_service.dart';

class Register extends StatefulWidget {
  final void Function()? onTap;

  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final String _freelancerRole = "freelancer";
  final String _avatar = "";
  final String _bioController = "";
  final String _addressController = "";
  final String _cityController = "";
  final String _positionController = "";
  final String _phoneNumberController = "";
  final num sumIncome = 0;
  final num numProjects = 0;
  final num numExpenses = 0;
  final num numProfits = 0;
  final List<String> skills = [];
  final List<String> experiences = [];

  final Timestamp _createdAt = Timestamp.now();

  bool? isChecked = false;

  //register method
  void register(BuildContext context) async {
    // Check if any required field is empty
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin!"),
        ),
      );
      return;
    }

    // Check if the password and confirm password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mật khẩu không khớp, vui lòng nhập lại!"),
        ),
      );
      return;
    }

    // Check if the terms and conditions are accepted
    if (isChecked == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hãy đồng ý với các điều khoản của chúng tôi!"),
        ),
      );
      return;
    }

    // Show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //get auth service
    final _auth = AuthService();

    try {
      await _auth.signUpWithEmailPassword(
        _emailController.text,
        _passwordController.text,
        _freelancerRole,
        _nameController.text,
        _avatar,
        _bioController,
        _addressController,
        _createdAt,
        _cityController,
        _positionController,
        _phoneNumberController,
        sumIncome,
        numProjects,
        numExpenses,
        numProfits,
        skills,
        experiences,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng ký thành công."),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePageFreelancer()),
        (route) => false,
      );
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error!"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message,
                    size: 100,
                    color: Color.fromRGBO(67, 101, 222, 1),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Đăng ký để tìm việc ngay",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFieldComponent(
                    content: "Họ và tên",
                    obscureText: false,
                    iconData: Icons.person_2_outlined,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldComponent(
                    content: "Email",
                    obscureText: false,
                    controller: _emailController,
                    iconData: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  PasswordFieldComponent(
                    content: "Mật khẩu",
                    iconData: Icons.lock_outlined,
                    controller: _passwordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  PasswordFieldComponent(
                    content: "Nhập lại mật khẩu",
                    iconData: Icons.lock_clock_outlined,
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                            value: isChecked,
                            activeColor: Color.fromRGBO(36, 160, 237, 1),
                            onChanged: (newBool) {
                              setState(() {
                                isChecked = newBool;
                              });
                            }),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: Text.rich(TextSpan(
                              text: "Tôi đã đọc và đồng ý với ",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.normal),
                              children: [
                                TextSpan(
                                  text: "Điều khoản dịch vụ",
                                  style: TextStyle(
                                    color: Color.fromRGBO(67, 101, 222, 1),
                                  ),
                                ),
                                TextSpan(
                                  text: " và ",
                                ),
                                TextSpan(
                                  text: "Chính sách bảo mật",
                                  style: TextStyle(
                                    color: Color.fromRGBO(67, 101, 222, 1),
                                  ),
                                ),
                                TextSpan(
                                  text: " của Freelancy.",
                                ),
                              ])),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyButton(onTap: () => register(context), text: "Đăng ký"),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn đã có tài khoản?",
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Đăng nhập ngay",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(67, 101, 222, 1)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
