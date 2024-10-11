// ignore_for_file: sort_child_properties_last

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/my_button.dart';
import 'package:freelancer/components/text_field_square.dart';

import 'package:freelancer/resources/add_data.dart';
import 'package:freelancer/utils.dart';
import 'package:image_picker/image_picker.dart';

class EditInfoFreelancer extends StatefulWidget {
  const EditInfoFreelancer({super.key});

  @override
  State<EditInfoFreelancer> createState() => _EditInfoFreelancerState();
}

class _EditInfoFreelancerState extends State<EditInfoFreelancer> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedCity = ""; // Default selected city
  String _selectedPosition = ""; // Default selected position

  String userName = "";
  String email = "";
  String avatar = "";
  Uint8List? _image;

  final List<String?> _cities = [
    "Hồ Chí Minh",
    "Hà Nội",
    "Đà Nẵng",
    "TP Hải Phòng",
    "Cần Thơ",
    // Add more cities as needed
  ];

  final List<String?> _positions = [
    "Nhạc công",
    "Ca sĩ",
    "Vũ công",
    "Thợ điện",
    "Giúp việc",
    // Add more cities as needed
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userName = doc['name'] ?? "";
        email = doc['email'] ?? "";
        avatar = doc['avatar'] ?? "";
        _nameController.text = userName;
        _phoneNumberController.text = doc['phoneNumber'] ?? "";
        _addressController.text = doc['address'] ?? "";
        _bioController.text = doc['bio'] ?? "";
        _selectedCity = doc['city']; // Default selected city
        _selectedPosition = doc['position']; // Default selected positionq
      });
    }
  }

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);

    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  Future<void> saveProfile() async {
    String name = _nameController.text;
    String bio = _bioController.text;
    String phoneNumber = _phoneNumberController.text;
    String address = _addressController.text;
    String city = _selectedCity;
    String position = _selectedPosition;

    if (_image == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Show a loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        String resp = await StoreData().saveDataWithoutAvatar(
          userId: userId, // Pass the user ID as a named parameter
          name: name,
          bio: bio,
          phoneNumber: phoneNumber,
          address: address,
          city: city,
          position: position,
        );

        // Close the loading indicator
        Navigator.pop(context);

        // Show an alert after saving
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Cập nhật thành công"),
              content: Text("Hồ sơ của bạn đã được cập nhật!"),
              actions: [
                TextButton(
                  child: Text(
                    "OK",
                    style: TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                  ),
                  onPressed: () {
                    // Navigate to the account page
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => HomePageFreelancer()),
                    //   (route) => false,
                    // );
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Show a loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        String resp = await StoreData().saveData(
          userId: userId, // Pass the user ID as a named parameter
          name: name,
          bio: bio,
          file: _image != null
              ? _image!
              : utf8
                  .encode(avatar), // Pass an empty Uint8List if _image is null
          phoneNumber: phoneNumber,
          address: address,
          city: city,
          position: position,
        );

        // Close the loading indicator
        Navigator.pop(context);

        // Show an alert after saving
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Cập nhật thành công"),
              content: Text("Hồ sơ của bạn đã được cập nhật!"),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    // Navigate to the account page
                    // Navigator.pushAndRemoveUntil(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => HomePageFreelancer()),
                    //   (route) => false,
                    // );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        title: Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white, // Add this line
                        child: CircleAvatar(
                          radius: 55, // Reduce the radius
                          backgroundImage: _image != null
                              ? MemoryImage(_image!)
                              : NetworkImage(avatar),
                        ),
                      ),
                    ),
                    Positioned(
                      child: IconButton(
                        onPressed: selectImage,
                        icon: Icon(Icons.add_a_photo),
                      ),
                      bottom: -14,
                      left: 75,
                    ),
                  ]),
                  SizedBox(height: 25),
                  TextFieldSquare(
                    title: "Họ và Tên",
                    content: "Họ và Tên",
                    obscureText: false,
                    controller: _nameController,
                    iconData: Icons.person,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 15),
                  TextFieldSquare(
                    title: "Số điện thoại",
                    content: "Số điện thoại",
                    obscureText: false,
                    controller: _phoneNumberController,
                    iconData: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFieldSquare(
                    title: "Địa chỉ",
                    content: "Địa chỉ",
                    obscureText: false,
                    controller: _addressController,
                    iconData: Icons.map,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Thành phố",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 17)),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey, width: 1.5)),
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, bottom: 5, right: 8),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.grey.shade200,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 30,
                              ),
                              value:
                                  _selectedCity.isEmpty ? null : _selectedCity,
                              hint: Text('Chọn thành phố'),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCity = newValue!;
                                });
                              },
                              items: _cities.map<DropdownMenuItem<String>>(
                                  (String? value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 20, left: 10),
                                    child: Text(value ?? ''),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nghề nghiệp",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal, fontSize: 17)),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.grey, width: 1.5)),
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, bottom: 5, right: 8),
                            child: DropdownButton<String>(
                              dropdownColor: Colors.grey.shade200,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 30,
                              ),
                              value: _selectedPosition.isEmpty
                                  ? null
                                  : _selectedPosition,
                              hint: Text('Chọn nghề nghiệp'),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPosition = newValue!;
                                });
                              },
                              items: _positions.map<DropdownMenuItem<String>>(
                                  (String? value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 20, left: 10),
                                    child: Text(value ?? ''),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Giới thiệu về bản thân",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 17)),
                      SizedBox(height: 10),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 1.5)),
                        padding: const EdgeInsets.only(
                            left: 10, top: 5, bottom: 5, right: 8),
                        child: TextField(
                          maxLines: null,
                          controller: _bioController,
                          style: const TextStyle(),
                          decoration: InputDecoration(
                              hintText: "Hãy chia sẻ một chút về bản thân bạn",
                              alignLabelWithHint: true,
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 17)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 25, right: 25, top: 30, bottom: 30),
              child: MyButton(
                onTap: () async {
                  await saveProfile();
                },
                text: "Lưu",
              ),
            )
          ],
        ),
      ),
    );
  }
}
