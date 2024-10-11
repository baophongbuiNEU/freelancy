// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:freelancer/components/my_button.dart';
import 'package:freelancer/components/password_field.dart';
import 'package:freelancer/components/text_field_circle.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/home_page_freelancer.dart';

class Login extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final void Function()? onTap;

  Login({super.key, required this.onTap});

  void loginGoogle(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.signInWithGoogle();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePageFreelancer()),
        (route) => false,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  void login(BuildContext context) async {
    //circle
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    //auth service
    final authService = AuthService();

    //try login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập thành công!."),
        ),
      );
      // Navigator.pushReplacement(context,
      //     MaterialPageRoute(builder: (context) => HomePageFreelancer()));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePageFreelancer()),
        (route) => false,
      );
    }

    //catch any errors
    catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            e.toString(),
          ),
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
                    Icons.work_outline,
                    size: 100,
                    color: Color.fromRGBO(67, 101, 222, 1),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Đăng Nhập để tìm việc ngay",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(
                    height: 30,
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
                    content: "Nhập mật khẩu",
                    iconData: Icons.lock_outlined,
                    controller: _passwordController,
                  ),
                  Row(
                    children: [
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                              color: Color.fromRGBO(67, 101, 222, 1),
                              fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  MyButton(onTap: () => login(context), text: "Đăng Nhập"),
                  const SizedBox(
                    height: 25,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey,
                  //         height: 0,
                  //         thickness: 0.5,
                  //         endIndent: 15,
                  //       ),
                  //     ),
                  //     Text(
                  //       "Hoặc đăng nhập bằng",
                  //       style: TextStyle(fontSize: 17, color: Colors.grey[800]),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey,
                  //         height: 0,
                  //         thickness: 0.5,
                  //         indent: 15,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SquareTile(
                  //       imagePath: 'lib/images/facebook.webp',
                  //       onTap: () {},
                  //     ),

                  //     SizedBox(width: 25),
                  //     // google button
                  //     SquareTile(
                  //       imagePath: 'lib/images/google.png',
                  //       onTap: () => loginGoogle(context),
                  //     ),

                  //     SizedBox(width: 25),

                  //     // apple button
                  //     SquareTile(
                  //       imagePath: 'lib/images/apple.png',
                  //       onTap: () {},
                  //     )
                  //   ],
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn chưa có tài khoản?",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: onTap,
                        child: Text(
                          "Đăng ký ngay",
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
