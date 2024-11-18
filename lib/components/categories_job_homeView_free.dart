import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelancer/pages/freelancer/pages_freelancer/jobs_list.dart';

class CategoriesJobHomeviewFree extends StatelessWidget {
  CategoriesJobHomeviewFree({super.key});
  final ref = FirebaseFirestore.instance.collection('jobs');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int columns = width > 600
            ? 8
            : width > 350
                ? 4
                : 2;

        // Calculate dynamic childAspectRatio based on available width and columns
        final double itemWidth = width / columns;
        final double itemHeight = itemWidth * 1.25; // Adjust height as needed
        final double childAspectRatio = itemWidth / itemHeight;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
          ),
          shrinkWrap: true, // Fit content height
          physics:
              NeverScrollableScrollPhysics(), // Prevent GridView from scrolling
          itemCount: 8, // Total number of items
          itemBuilder: (context, index) {
            final categoryData = _getCategoryData(index);
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      JobListPage(categoryTitle: categoryData['title']!),
                ),
              ),
              child: taskCategory(
                  categoryData['image']!, categoryData['title']!, context),
            );
          },
        );
      },
    );
  }

  Map<String, String> _getCategoryData(int index) {
    final categories = [
      {
        'title': 'Ban nhạc',
        'image':
            'https://th.bing.com/th/id/OIP.SyTLFuM9Ev5ABWZHFS1vowHaEQ?rs=1&pid=ImgDetMain'
      },
      {
        'title': 'Cà phê',
        'image':
            'https://coffeeshopstartups.com/wp-content/uploads/2022/06/barista-3-1024x576.png'
      },
      {
        'title': 'Dancer',
        'image':
            'https://th.bing.com/th/id/OIP.EDbuoyue51h-SvQP4XaX-wAAAA?rs=1&pid=ImgDetMain'
      },
      {
        'title': 'Giúp việc',
        'image':
            'https://th.bing.com/th/id/R.1ea03333f521b62dcf20b98ff8d9b929?rik=zvWaqnZ6tk4vEA&riu=http%3a%2f%2fgiupviecgiaphu.com%2fupload%2fimages%2fthue-nguoi-giup-viec-bao-an-o-lai(1).jpg&ehk=luWfY53neo6SNnv3nF7KWDlQhbyLaCllaR7UkFylPOE%3d&risl=&pid=ImgRaw&r=0'
      },
      {
        'title': 'Nội thất',
        'image':
            'https://kamaxpaint.com/wp-content/uploads/2021/07/su-co-son-nha.png'
      },
      {
        'title': 'Thợ điện',
        'image':
            'https://static.chotot.com/storage/chotot-kinhnghiem/c2c/2020/12/tho-dien-tim-viec.jpg'
      },
      {
        'title': 'Vận chuyển',
        'image':
            'https://chuyennha24h.net/wp-content/uploads/2020/07/chuyen-van-phong-chuyen-nghiep-tai-can-gio.jpg'
      },
      {
        'title': 'Âm thanh',
        'image':
            'https://sukienachau.com/wp-content/uploads/2015/09/19959332_1851909594836136_6336863231639011256_n.jpg'
      },
    ];
    return categories[index];
  }

  Container taskCategory(String image, String title, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 65,
            height: 65,
            child: CircleAvatar(
              backgroundImage: NetworkImage(image),
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
