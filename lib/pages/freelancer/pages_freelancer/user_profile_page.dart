import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/image_viewer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/edit_info_freelancer.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = "";
  String email = "";
  String avatar = "";
  String city = "";
  String phoneNumber = "";
  String address = "";
  String position = "";
  String bio = "";
  TextEditingController skillController = TextEditingController();
  final List<String> _skills = [];
  bool _isEditing = false;

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

      if (mounted) {
        setState(() {
          userName = doc['name'] ?? "";
          email = doc['email'] ?? "";
          avatar = doc['avatar'] ?? "";
          city = doc['city'] ?? "";
          phoneNumber = doc['phoneNumber'] ?? "Chưa cập nhật";
          address = doc['address'] ?? "Chưa cập nhật";
          position = doc['position'] ?? "Chưa cập nhật";
          bio = doc['bio'] ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final doc = snapshot.data!;
            userName = doc['name'] ?? "";
            email = doc['email'] ?? "";
            avatar = doc['avatar'] ?? "";
            bio = doc['bio'] ?? "";
            address = doc['address'];
            city = doc['city'] ?? "";
            phoneNumber = doc['phoneNumber'] ?? "Chưa cập nhật";
            position = doc['position'] ?? "Chưa cập nhật";
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title:
                  Text('Hồ sơ cá nhân', style: TextStyle(color: Colors.black)),
              actions: [
                IconButton(
                  icon: Icon(Icons.share, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(),
                  SizedBox(height: 16),
                  _buildSkillsCard(),
                  SizedBox(height: 16),
                  _buildExperienceCard(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: Stack(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade500, Colors.blue.shade600],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: 20,
                width: 130,
                height: 130,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageViewer(image: avatar)));
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white, // Add this line
                    child: CircleAvatar(
                      radius: 60, // Reduce the radius
                      backgroundImage: NetworkImage(avatar),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(position,
                            style: TextStyle(color: Colors.grey, fontSize: 17)),
                      ],
                    ),
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.black,
                      ),
                      label: Text('Chỉnh sửa',
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditInfoFreelancer(),
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  bio,
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.email, email),
                _buildInfoRow(Icons.phone, phoneNumber),
                _buildInfoRow(Icons.location_on, address),
                _buildInfoRow(Icons.business, city),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue.shade500),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kỹ năng',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            _isEditing
                ? Column(
                    children: [
                      TextField(
                        controller: skillController,
                        decoration: InputDecoration(
                          hintText: 'Nhập kỹ năng mới',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          if (skillController.text.isNotEmpty) {
                            setState(() {
                              _skills.add(skillController.text);
                              skillController.clear();
                            });
                          }
                        },
                        child: Text('Thêm kỹ năng'),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) => _buildSkillChip(skill)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExperienceCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kinh nghiệm làm việc',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildExperienceItem(
              'Senior Software Engineer',
              'Công ty ABC',
              '2020 - Hiện tại',
            ),
            SizedBox(height: 16),
            _buildExperienceItem(
              'Software Developer',
              'Công ty XYZ',
              '2018 - 2020',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(company, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 2),
        Text(period, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
