import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/feedback.dart';
import 'package:intl/intl.dart';

class PaymentConfirmationDialog extends StatefulWidget {
  final String salary;
  final String uid;
  final String? jobID;
  final String jobTitle;
  final String clientName;
  final String employerName;
  final int accepted;
  // final int numberCandidates;

  const PaymentConfirmationDialog({
    super.key,
    required this.salary,
    required this.uid,
    required this.jobID,
    required this.jobTitle,
    required this.clientName,
    required this.employerName,
    required this.accepted,
    // required this.numberCandidates,
  });

  @override
  _PaymentConfirmationDialogState createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> {
  final TextEditingController _tipsController = TextEditingController();
  double _totalAmount = 0.0;
  // List<String> accepted = [];
  // num numberCandidates = 0;

  @override
  void initState() {
    super.initState();
    _totalAmount = double.parse(widget.salary);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      title: Text('Xác nhận thanh toán'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số tiền thanh toán: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(num.parse(widget.salary))}',
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            controller: _tipsController,
            decoration: InputDecoration(
                labelText: 'Số tiền tips',
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(67, 101, 222, 1)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(67, 101, 222, 1)),
                ),
                labelStyle: TextStyle(
                    color: Color.fromRGBO(67, 101, 222, 1), fontSize: 16)),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _totalAmount = double.parse(widget.salary) +
                    double.parse(value.isEmpty ? '0' : value);
              });
            },
          ),
          SizedBox(height: 16),
          Text(
            'Tổng số tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_totalAmount)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style:
                TextStyle(color: Color.fromRGBO(67, 101, 222, 1), fontSize: 16),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                title: Text('Thanh toán thành công!'),
                content: Text(
                  'Hãy để lại đánh giá',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Bỏ qua',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerFeedbackPage(
                            customerID: widget.uid,
                            jobID: widget.jobID,
                          ),
                        )),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(67, 101, 222, 1),
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Text(
                        'Đánh giá ngay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
            await FirebaseFirestore.instance
                .collection('finance')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              'numExpenses':
                  FieldValue.increment(num.parse(_totalAmount.toString())),
            });
            FirebaseFirestore.instance
                .collection('finance')
                .doc(widget.uid)
                .update({
              'numProjects': FieldValue.increment(1),
              'income':
                  FieldValue.increment(num.parse(_totalAmount.toString())),
            });

            DocumentReference notiPlus = FirebaseFirestore.instance
                .collection("notifications")
                .doc(); // Generate a unique document ID
            notiPlus.set({
              'clicked': false,
              'type': 'finance_noti',
              'clientName': widget.clientName,
              'jobTitle': widget.jobTitle,
              'jobID': widget.jobID,
              'candidateID': widget.uid,
              'salary': num.parse(_totalAmount.toString()),
              'employerUID': FirebaseAuth.instance.currentUser!.uid,
              'timestamp': Timestamp.now(),
              'employerName': widget.employerName,
            });

            // Check if the job is complete and update the category
            // if (widget.accepted == widget.numberCandidates) {
            await FirebaseFirestore.instance
                .collection('jobs')
                .doc(widget.jobID)
                .update({
              'category': 'Done',
            });
            // }
          },
          child: Text(
            'Xác nhận',
            style: TextStyle(
              color: Color.fromRGBO(67, 101, 222, 1),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// class PaymentConfirmationScreen extends StatelessWidget {
//   final String totalAmount;

//   const PaymentConfirmationScreen({super.key, required this.totalAmount});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Xác nhận thanh toán'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Thanh toán thành công!'),
//             SizedBox(height: 16),
//             Text('Tổng số tiền đã thanh toán: $totalAmount'),
//           ],
//         ),
//       ),
//     );
//   }
// }
