import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class UploadPost extends StatefulWidget {
  UploadPost({super.key, required this.gallery, required this.selectedRole});

  final bool gallery;
  String selectedRole;
  @override
  State<UploadPost> createState() => _UploadPostState();
}

class _UploadPostState extends State<UploadPost> {
  File? _pickedImage;
  final TextEditingController _textController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  late Map<String, dynamic> userData;
  String userName = "";
  String email = "";
  String receiverID = "";
  String avatar = "";
  String message = "";
  String position = "";

  final List<String?> _roles = [
    "Ứng viên",
    "Chia sẻ",
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    if (widget.gallery != true) {
      _pickImage();
    } else {}
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          userName = doc['name'] ?? "";
          email = doc['email'] ?? "";
          avatar = doc['avatar'] ?? "";
          position = doc['position'] ?? "";
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void postPost() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    if (widget.selectedRole.isNotEmpty) {
      if (_textController.text.isNotEmpty || _pickedImage != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          final userName = doc['name'] ?? "";
          final avatar = doc['avatar'] ?? "";

          if (_pickedImage != null) {
            // Upload the image to Firebase Storage
            final ref = FirebaseStorage.instance.ref().child(
                'posts/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

            final uploadTask = ref.putFile(_pickedImage!);
            final imageUrl =
                await uploadTask.then((value) => value.ref.getDownloadURL());

            // Add the post with the image URL to Firestore
            FirebaseFirestore.instance.collection("posts").add({
              'uid': user.uid,
              'category': widget.selectedRole,
              'content': _textController.text,
              'image': imageUrl, // Add the image URL to the post
              'timestamp': Timestamp.now(),
              'likes': [],
            });
          } else {
            // Add the post without an image to Firestore
            FirebaseFirestore.instance.collection("posts").add({
              'uid': user.uid,
              'content': _textController.text,
              'image': "", // Add the image URL to the post
              'category': widget.selectedRole,
              'timestamp': Timestamp.now(),
              'likes': [],
            });
          }
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text("Thành công"),
                content: Text("Bài viết mới của bạn đã được đăng tải!"),
                actions: [
                  TextButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        }
      } else if (_textController.text.isEmpty || _pickedImage == null) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Thông báo"),
              content: Text("Vui lòng chọn nhập nội dung muốn đăng!"),
              actions: [
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } else if (widget.selectedRole.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Thông báo"),
            content: Text("Vui lòng chọn loại bài viết!"),
            actions: [
              TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text("Tạo bài viết"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => postPost(),
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 17),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(67, 101, 222, 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                "Chia sẻ",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.photo_library),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 208, 234, 255),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(style: BorderStyle.none)),
                        padding: const EdgeInsets.only(left: 10, right: 8),
                        child: DropdownButton<String>(
                          dropdownColor: Color.fromARGB(255, 208, 234, 255),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Color.fromRGBO(67, 101, 222, 1),
                            size: 30,
                          ),
                          value: widget.selectedRole,
                          hint: Text(
                            'Chọn vai trò',
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              widget.selectedRole = newValue!;
                            });
                          },
                          items: _roles
                              .map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                child: Text(
                                  value ?? '',
                                  style: TextStyle(
                                      color: Color.fromRGBO(67, 101, 222, 1),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
              child: TextField(
                controller: _textController,
                maxLines: null, // Allow TextField to wrap content
                style: TextStyle(color: Colors.black, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Bạn đang nghĩ gì?',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _pickedImage != null
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Image.file(_pickedImage!),
                      // IconButton(
                      //   icon: Icon(Icons.delete),
                      //   color: Colors.black,
                      // onPressed: () {
                      //   setState(() {
                      //     _pickedImage = null;
                      //   });
                      // },
                      // ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _pickedImage = null;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          margin: EdgeInsets.only(right: 10, top: 10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "x",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      )
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }
}
