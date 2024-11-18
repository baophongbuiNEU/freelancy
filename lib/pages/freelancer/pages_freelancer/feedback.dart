import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerFeedbackPage extends StatefulWidget {
  const CustomerFeedbackPage(
      {super.key, required this.customerID, required this.jobID});
  final String? customerID;
  final String? jobID;

  @override
  _CustomerFeedbackPageState createState() => _CustomerFeedbackPageState();
}

class _CustomerFeedbackPageState extends State<CustomerFeedbackPage> {
  int _rating = 0;

  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  void _submitFeedback() async {
    try {
      await FirebaseFirestore.instance.collection('feedbacks').doc().set({
        'rating': _rating,
        'feedback': _feedbackController.text,
        'timestamp': Timestamp.now(),
        'customerID': widget.customerID,
        'employerUID': FirebaseAuth.instance.currentUser!.uid,
        'jobID': widget.jobID,
      });
      DocumentReference notiPlus = FirebaseFirestore.instance
          .collection("notifications")
          .doc(); // Generate a unique document ID
      notiPlus.set({
        'clicked': false,
        'category': "feedback",
        'type': 'feedback_noti',
        'jobID': widget.jobID,
        'candidateID': widget.customerID,
        'employerUID': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': Timestamp.now(),
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          title: Text('Phản hồi đã được gửi'),
          content:
              Text('Cảm ơn bạn đã gửi phản hồi. Chúng tôi rất trân trọng.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Close the feedback page
              },
              child: Text(
                'Đóng',
                style: TextStyle(
                    fontSize: 16, color: Color.fromRGBO(67, 101, 222, 1)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi gửi phản hồi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        title: Text('Phản hồi khách hàng'),
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Chúng tôi rất trân trọng ý kiến của bạn. Hãy chia sẻ trải nghiệm của bạn với chúng tôi!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                Text('Đánh giá tổng thể',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _feedbackController,
                  decoration: InputDecoration(
                      labelText: 'Chi tiết phản hồi',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(
                          color: Color.fromRGBO(67, 101, 222, 1), fontSize: 16),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2,
                              color: Color.fromRGBO(67, 101, 222, 1))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2,
                              color: Color.fromRGBO(67, 101, 222, 1)))),
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập chi tiết phản hồi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      padding: EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Color.fromRGBO(67, 101, 222, 1)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đang xử lý phản hồi')),
                      );
                      _submitFeedback();
                    }
                  },
                  child: Text(
                    'Gửi phản hồi',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
