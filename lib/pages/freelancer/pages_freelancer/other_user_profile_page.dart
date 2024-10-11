import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/components/image_viewer.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/chat_page.dart';

class OtherUserProfilePage extends StatefulWidget {
  final String userId;
  const OtherUserProfilePage({super.key, required this.userId});

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userData;

  @override
  void initState() {
    super.initState();
    _userData =
        FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Hồ sơ cá nhân', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!.data();
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileCard(user!),
                  SizedBox(height: 16),
                  _buildSkillsCard(),
                  SizedBox(height: 16),
                  _buildExperienceCard(),
                  SizedBox(height: 16),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> user) {
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
                            builder: (context) =>
                                ImageViewer(image: user['avatar'])));
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white, // Add this line
                    child: CircleAvatar(
                      radius: 60, // Reduce the radius
                      backgroundImage: NetworkImage(user['avatar']),
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
                          user['name'],
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(user['position'],
                            style: TextStyle(color: Colors.grey, fontSize: 17)),
                      ],
                    ),
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.message,
                        size: 16,
                        color: Color.fromRGBO(67, 101, 222, 1),
                      ),
                      label: Text('Liên hệ',
                          style: TextStyle(
                              color: Color.fromRGBO(67, 101, 222, 1),
                              fontSize: 16)),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiverEmail: user['name'],
                              receiverID: user['uid'],
                              avatar: user['avatar'],
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OtherUserProfilePage(
                                              userId: user["uid"],
                                            )));
                              },
                            ),
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  user['bio'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 17),
                ),
                SizedBox(height: 16),
                _buildInfoRow(Icons.email, user['email']),
                _buildInfoRow(Icons.phone, user['phoneNumber']),
                _buildInfoRow(Icons.location_on, user['address']),
                _buildInfoRow(Icons.business, user['city']),
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
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kỹ năng',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),

            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   children: _skills.map((skill) => _buildSkillChip(skill)).toList(),
            // ),
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
