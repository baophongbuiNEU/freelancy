import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:freelancer/services/auth/auth_service.dart';
import 'package:intl/intl.dart';

class UploadJobs extends StatefulWidget {
  UploadJobs({super.key, required this.gallery});
  bool gallery;
  @override
  State<UploadJobs> createState() => _UploadJobsState();
}

class _UploadJobsState extends State<UploadJobs> {
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
  List<String> enrolls = [];
  List<String> accepted = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    if (widget.gallery != true) {
      // _pickImage();
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

  void postJob() async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    if (_formKey.currentState!.validate() || _pickedImage != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final userName = doc['name'] ?? "";
        final avatar = doc['avatar'] ?? "";
        String jobID = FirebaseFirestore.instance.collection("jobs").doc().id;

        if (_pickedImage != null) {
          // Upload the image to Firebase Storage
          final ref = FirebaseStorage.instance.ref().child(
              'posts/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

          final uploadTask = ref.putFile(_pickedImage!);
          final imageUrl =
              await uploadTask.then((value) => value.ref.getDownloadURL());

          // Add the post with the image URL to Firestore
          FirebaseFirestore.instance.collection("jobs").doc(jobID).set({
            'uid': user.uid,
            'description': _descriptionController.text,
            'title': _titleController.text,
            'enroll_start_time': Timestamp.fromDate(_startDate!),
            'enroll_end_time': Timestamp.fromDate(_endDate!),
            'location': _locationController.text,
            'requirement': _requirementController.text,
            'salary': _salaryController.text,
            'skills': _skillsController.text,
            'experience': _experienceLevel,
            'happening_time': Timestamp.fromDate(_happeningDate!),
            'image': imageUrl, // Add the image URL to the post
            'category': _role,
            'timestamp': Timestamp.now(),
            'jobID': jobID,
            'enrolls': enrolls,
            'accepted': accepted,
          });
        } else {
          // Add the post without an image to Firestore
          FirebaseFirestore.instance.collection("jobs").doc(jobID).set({
            'uid': user.uid,
            'description': _descriptionController.text,
            'title': _titleController.text,
            'enroll_start_time': Timestamp.fromDate(_startDate!),
            'enroll_end_time': Timestamp.fromDate(_endDate!),
            'location': _locationController.text,
            'requirement': _requirementController.text,
            'salary': _salaryController.text,
            'skills': _skillsController.text,
            'experience': _experienceLevel,
            'happening_time': Timestamp.fromDate(_happeningDate!),
            'category': _role,
            'timestamp': Timestamp.now(),
            'jobID': jobID,
            'enrolls': enrolls,
            'accepted': accepted,
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
    }
  }
  //new

  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _startTime;
  DateTime? _endTime;

  DateTime? _endDate;
  String? _experienceLevel;
  DateTime? _happeningDate;
  TimeOfDay? _happeningHour;
  String? _role;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text(
          'Đăng tin tuyển dụng',
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (_formKey.currentState!.validate()) {
                // Process data
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang xử lý dữ liệu')),
                );
                postJob();
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(67, 101, 222, 1),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                "Đăng bài",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                  ),
                  value: _role,
                  items: const [
                    DropdownMenuItem(
                        value: 'Ban nhạc', child: Text('Ban nhạc')),
                    DropdownMenuItem(value: 'Cà phê', child: Text('Cà phê')),
                    DropdownMenuItem(value: 'Dancer', child: Text('Dancer')),
                    DropdownMenuItem(
                        value: 'Giúp việc', child: Text('Giúp việc')),
                    DropdownMenuItem(
                        value: 'Nội thất', child: Text('Nội thất')),
                    DropdownMenuItem(
                        value: 'Thợ điện', child: Text('Thợ điện')),
                    DropdownMenuItem(
                        value: 'Vận chuyển', child: Text('Vận chuyển')),
                    DropdownMenuItem(
                        value: 'Âm thanh', child: Text('Âm thanh')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _role = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn danh mục';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'Tiêu đề công việc',
                      hintText: 'Ví dụ: Kỹ sư phần mềm Full-stack',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      ),
                      floatingLabelStyle:
                          TextStyle(color: Color.fromRGBO(67, 101, 222, 1))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề công việc';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả công việc',
                    hintText:
                        'Mô tả chi tiết về công việc, trách nhiệm, và môi trường làm việc',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả công việc';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text('Thời gian tuyển dụng',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Ngày bắt đầu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5),
                          ),
                          floatingLabelStyle:
                              TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _startDate != null
                              ? DateFormat('dd/MM/yyyy HH:mm')
                                  .format(_startDate!)
                              : '',
                        ),
                        onTap: () async {
                          final picked = await DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            maxTime: DateTime.now().add(Duration(days: 365)),
                            onChanged: (date) {
                              setState(() => _startDate = date);
                            },
                            onConfirm: (date) {
                              setState(() => _startDate = date);
                            },
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập ngày bắt đầu';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Ngày kết thúc',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                                color: Color.fromRGBO(67, 101, 222, 1),
                                width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.5),
                          ),
                          floatingLabelStyle:
                              TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: _endDate != null
                              ? DateFormat('dd/MM/yyyy HH:mm').format(_endDate!)
                              : '',
                        ),
                        onTap: () async {
                          final picked = await DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            minTime: _startDate,
                            maxTime: DateTime.now().add(Duration(days: 365)),
                            onChanged: (date) {
                              setState(() => _endDate = date);
                            },
                            onConfirm: (date) {
                              setState(() => _endDate = date);
                            },
                          );
                          if (picked != null) setState(() => _endDate = picked);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập ngày kết thúc';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Địa điểm làm việc',
                    hintText: 'Ví dụ: Hà Nội',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Color.fromRGBO(67, 101, 222, 1),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa điểm làm việc';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelText: 'Mức lương',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                    hintText: 'VNĐ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mức lương tối thiểu';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Kinh nghiệm yêu cầu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                  ),
                  value: _experienceLevel,
                  items: const [
                    DropdownMenuItem(
                        value: 'Mới đi làm', child: Text('Mới đi làm')),
                    DropdownMenuItem(value: '1-3 năm', child: Text('1-3 năm')),
                    DropdownMenuItem(value: '3-5 năm', child: Text('3-5 năm')),
                    DropdownMenuItem(value: '5+ năm', child: Text('5+ năm')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _experienceLevel = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn mức kinh nghiệm';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _skillsController,
                  decoration: InputDecoration(
                    labelText: 'Yêu cầu ứng viên',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                    hintText:
                        'Liệt kê các kỹ năng, bằng cấp, hoặc yêu cầu khác cho ứng viên',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập yêu cầu ứng viên';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Ngày diễn ra',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(
                          color: Color.fromRGBO(67, 101, 222, 1), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    floatingLabelStyle:
                        TextStyle(color: Color.fromRGBO(67, 101, 222, 1)),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _happeningDate != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(_happeningDate!)
                        : '',
                  ),
                  onTap: () async {
                    final picked = await DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: _startDate,
                      maxTime: DateTime.now().add(Duration(days: 365)),
                      onChanged: (date) {
                        setState(() => _happeningDate = date);
                      },
                      onConfirm: (date) {
                        setState(() => _happeningDate = date);
                      },
                    );
                    if (picked != null) setState(() => _happeningDate = picked);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập ngày diễn ra công việc';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
