import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildJobCard();
  }
  Widget _buildJobCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(
                  backgroundImage: AssetImage(""),
                  radius: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("job.title",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("job.company", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                // if (showStatus) _buildStatusChip(job.status!),
                // if (showApplicationStatus)
                //   _buildApplicationStatusChip(job.applicationStatus!),
              ],
            ),
            SizedBox(height: 16),
            Text("job.description", style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, "job.location"),
            // _buildInfoRow(Icons.calendar_today,
            //     'Đăng ngày: ${DateFormat('dd/MM/yyyy').format(job.postedDate)}'),
            // _buildInfoRow(Icons.timer,
            //     'Hạn chót: ${DateFormat('dd/MM/yyyy').format(job.deadline)}'),
            // if (showEnrolledCount)
            //   _buildInfoRow(
            //       Icons.people, 'Số người ứng tuyển: ${job.enrolledCount}'),
            // if (showApplicationStatus && job.enrolledDate != null)
            //   _buildInfoRow(Icons.how_to_reg,
            //       'Đã ứng tuyển: ${DateFormat('dd/MM/yyyy').format(job.enrolledDate!)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status == 'open' ? 'Đang mở' : 'Đã đóng',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: status == 'open' ? Colors.green : Colors.grey,
    );
  }

  Widget _buildApplicationStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'enrolled':
        color = Colors.blue;
        text = 'Đã ứng tuyển';
        break;
      case 'accepted':
        color = Colors.green;
        text = 'Chấp nhận';
        break;
      case 'declined':
        color = Colors.red;
        text = 'Từ chối';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
    }
    return Chip(
      label: Text(text, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}