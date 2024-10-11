import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _filter = 'all';

  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'type': 'enrollment',
      'person': {'name': 'Nguyễn Văn A', 'avatar': 'assets/avatar1.png'},
      'content': 'đã ứng tuyển vào vị trí',
      'jobTitle': 'Kỹ sư phần mềm',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
    },
    {
      'id': '2',
      'type': 'message',
      'person': {'name': 'Trần Thị B', 'avatar': 'assets/avatar2.png'},
      'content': 'Xin chào, tôi muốn hỏi thêm về vị trí Nhà thiết kế UX/UI',
      'timestamp': DateTime.now().subtract(Duration(minutes: 30)),
    },
    {
      'id': '3',
      'type': 'result',
      'person': {'name': 'Công ty XYZ', 'avatar': 'assets/company1.png'},
      'content': 'đã phản hồi đơn ứng tuyển của bạn',
      'jobTitle': 'Quản lý dự án',
      'result': 'accept',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      'id': '4',
      'type': 'enrollment',
      'person': {'name': 'Lê Văn C', 'avatar': 'assets/avatar3.png'},
      'content': 'đã ứng tuyển vào vị trí',
      'jobTitle': 'Chuyên viên marketing',
      'timestamp': DateTime.now().subtract(Duration(hours: 3)),
    },
    {
      'id': '5',
      'type': 'result',
      'person': {'name': 'Công ty ABC', 'avatar': 'assets/company2.png'},
      'content': 'đã phản hồi đơn ứng tuyển của bạn',
      'jobTitle': 'Kỹ sư AI',
      'result': 'decline',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _filter == 'all'
        ? notifications
        : notifications.where((notif) => notif['type'] == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('Tất cả', 'all'),
                  _buildFilterButton('Ứng tuyển', 'enrollment'),
                  _buildFilterButton('Tin nhắn', 'message'),
                  _buildFilterButton('Kết quả', 'result'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return _buildNotificationItem(notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () => setState(() => _filter = value),
        style: ElevatedButton.styleFrom(
          foregroundColor: _filter == value ? Colors.white : Colors.black,
          backgroundColor: _filter == value
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(notification['person']['avatar']),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: notification['person']['name'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(
                  text: ' ${notification['content']} ',
                  style: TextStyle(color: Colors.black)),
              if (notification['jobTitle'] != null)
                TextSpan(
                    text: notification['jobTitle'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification['type'] == 'message')
              Text(notification['content'],
                  style: TextStyle(color: Colors.grey[600])),
            if (notification['type'] == 'result')
              Chip(
                label: Text(
                  notification['result'] == 'accept' ? 'Chấp nhận' : 'Từ chối',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: notification['result'] == 'accept'
                    ? Colors.green
                    : Colors.red,
              ),
            Text(
              _formatTimestamp(notification['timestamp']),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: _getNotificationIcon(notification['type']),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'enrollment':
        iconData = Icons.work;
        color = Colors.blue;
        break;
      case 'message':
        iconData = Icons.message;
        color = Colors.green;
        break;
      case 'result':
        iconData = Icons.notifications;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.error;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
