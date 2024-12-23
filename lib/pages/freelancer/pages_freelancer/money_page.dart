import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/done_job.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/total_expense.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/total_income.dart';

import 'package:intl/intl.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  num sumIncome = 0;
  num numProjects = 0;
  num numExpenses = 0;
  num numProfits = 0;
  late TabController _tabController;

  String userName = "";
  String myName = "";
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('finance')
          .doc(user.uid)
          .get();

      setState(() {
        userName = doc['name'] ?? "";
        sumIncome = doc['income'] ?? "";
        numProjects = doc['numProjects'] ?? "";
        numExpenses = doc['numExpenses']; // Default selected city
        numProfits = sumIncome - numExpenses; // Default selected positionq
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

// Define the maximum number of characters based on the device width
    int maxCharacters =
        deviceWidth < 500 ? 10 : 30; // Adjust the value as needed

    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        title: Text('Lịch sử Giao dịch'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(deviceWidth),
              SizedBox(height: 24),
              _buildTab(maxCharacters),
              SizedBox(height: 24),
              // _buildNewTransactionForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(double deviceWidth) {
    return GridView.count(
      crossAxisCount: deviceWidth > 500 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TotalIncome(),
              )),
          child: _buildOverviewCard(
              'Tổng thu nhập',
              NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                  .format(sumIncome),
              'Ấn để xem chi tiết',
              Icons.attach_money),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoneJob(),
              )),
          child: _buildOverviewCard(
              'Đã hoàn thành',
              NumberFormat.currency(locale: 'vi_VN', symbol: '')
                  .format(numProjects),
              'Ấn để xem chi tiết',
              Icons.work_outline),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TotalExpense(),
              )),
          child: _buildOverviewCard(
              'Chi phí',
              NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                  .format(numExpenses),
              'Ấn để xem chi tiết',
              Icons.arrow_downward),
        ),
        _buildProfitCard('Lợi nhuận', numProfits, '', Icons.trending_up),
      ],
    );
  }

  Widget _buildOverviewCard(
      String title, String value, String change, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(67, 101, 222, 1), width: 2),
        borderRadius: BorderRadius.circular(12), // Add border radius here
// Change the border color and width here
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(67, 101, 222, 1))),
                ),
                Expanded(
                    flex: 0,
                    child: Icon(icon,
                        size: 23, color: Color.fromRGBO(67, 101, 222, 1))),
              ],
            ),
            SizedBox(height: 8),
            Text(value.toString(),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(change, style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitCard(
      String title, num value, String change, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(67, 101, 222, 1), width: 2),
        borderRadius: BorderRadius.circular(12), // Add border radius here
// Change the border color and width here
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(67, 101, 222, 1))),
                Icon(icon, size: 23, color: Color.fromRGBO(67, 101, 222, 1)),
              ],
            ),
            SizedBox(height: 8),
            Text(
                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                    .format(value),
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: value > 0 ? Colors.green : Colors.red)),
            SizedBox(height: 4),
            Text(change, style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int maxCharacters) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(67, 101, 222, 1), width: 2),
        borderRadius: BorderRadius.circular(12), // Add border radius here
// Change the border color and width here
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Giao dịch gần đây',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TabBar(
                indicatorColor: Color.fromRGBO(67, 101, 222, 1),
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Thu nhập'),
                  Tab(text: 'Chi phí'),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 350,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCandidateNotifications(
                      maxCharacters), // StreamBuilder for candidate notifications
                  _buildEmployerNotifications(
                      maxCharacters), // StreamBuilder for employer notifications
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployerNotifications(int maxCharacters) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where("type", isEqualTo: "finance_noti")
          .where('employerUID',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data!.docs
            .where((doc) =>
                doc['employerUID'] == FirebaseAuth.instance.currentUser!.uid)
            .toList();

        if (notifications.isEmpty) {
          return Center(
            child: Text(
              'Không có giao dịch gần đây',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: ['Mô tả', 'Khách hàng', 'Số tiền', 'Ngày']
                        .map((header) => TableCell(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  header,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  ...notifications.map((notification) => TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              notification['jobTitle'].length > maxCharacters
                                  ? "${notification['jobTitle'].substring(0, maxCharacters)}..."
                                  : notification['jobTitle'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              notification['clientName'] ?? '-',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              "-${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(notification['salary'])}",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              DateFormat('dd/MM')
                                  .format(notification['timestamp'].toDate()),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCandidateNotifications(int maxCharacters) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where("type", isEqualTo: "finance_noti")
          .where('candidateID',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data!.docs
            .where((doc) =>
                doc['candidateID'] == FirebaseAuth.instance.currentUser!.uid)
            .toList();

        if (notifications.isEmpty) {
          return Center(
            child: Text(
              'Không có giao dịch gần đây',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: ['Mô tả', 'Khách hàng', 'Số tiền', 'Ngày']
                        .map((header) => TableCell(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  header,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  ...notifications.map((notification) => TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              notification['jobTitle'].length > maxCharacters
                                  ? "${notification['jobTitle'].substring(0, maxCharacters)}..."
                                  : notification['jobTitle'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              notification['employerName'] ?? '-',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              "+${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(notification['salary'])}",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              DateFormat('dd/MM')
                                  .format(notification['timestamp'].toDate()),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewTransactionForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thêm giao dịch mới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Loại giao dịch'),
              items: ['Thu nhập', 'Chi phí'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Số tiền'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Mô tả'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Khách hàng'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Ngày giao dịch'),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement add transaction logic
              },
              child: Text('Thêm giao dịch'),
            ),
          ],
        ),
      ),
    );
  }
}
