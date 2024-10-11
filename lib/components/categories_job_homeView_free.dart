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
            ? 4
            : width > 400
                ? 3
                : 2;

        return GridView.count(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JobListPage(categoryTitle: "Ban nhạc"),
                  )),
              child: taskCategory(
                  "https://th.bing.com/th/id/OIP.SyTLFuM9Ev5ABWZHFS1vowHaEQ?rs=1&pid=ImgDetMain",
                  "Ban nhạc",
                  context),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobListPage(categoryTitle: "Cà phê"),
                  )),
              child: taskCategory(
                  "https://coffeeshopstartups.com/wp-content/uploads/2022/06/barista-3-1024x576.png",
                  "Cà phê",
                  context),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobListPage(categoryTitle: "Dancer"),
                  )),
              child: taskCategory(
                  "https://th.bing.com/th/id/OIP.EDbuoyue51h-SvQP4XaX-wAAAA?rs=1&pid=ImgDetMain",
                  "Dancer",
                  context),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JobListPage(categoryTitle: "Giúp việc"),
                  )),
              child: taskCategory(
                  "https://th.bing.com/th/id/R.1ea03333f521b62dcf20b98ff8d9b929?rik=zvWaqnZ6tk4vEA&riu=http%3a%2f%2fgiupviecgiaphu.com%2fupload%2fimages%2fthue-nguoi-giup-viec-bao-an-o-lai(1).jpg&ehk=luWfY53neo6SNnv3nF7KWDlQhbyLaCllaR7UkFylPOE%3d&risl=&pid=ImgRaw&r=0",
                  "Giúp việc",
                  context),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JobListPage(categoryTitle: "Nội thất"),
                  )),
              child: taskCategory(
                  "https://kamaxpaint.com/wp-content/uploads/2021/07/su-co-son-nha.png",
                  "Nội thất",
                  context),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JobListPage(categoryTitle: "Thợ điện"),
                  )),
              child: taskCategory(
                  "https://static.chotot.com/storage/chotot-kinhnghiem/c2c/2020/12/tho-dien-tim-viec.jpg",
                  "Thợ điện",
                  context),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JobListPage(categoryTitle: "Vận chuyển"),
                  )),
              child: taskCategory(
                  "https://chuyennha24h.net/wp-content/uploads/2020/07/chuyen-van-phong-chuyen-nghiep-tai-can-gio.jpg",
                  "Vận chuyển",
                  context),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JobListPage(categoryTitle: "Âm thanh"),
                  )),
              child: taskCategory(
                  "https://sukienachau.com/wp-content/uploads/2015/09/19959332_1851909594836136_6336863231639011256_n.jpg",
                  "Âm thanh ánh sáng",
                  context),
            ),
          ],
        );
      },
    );
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:freelancer/models/categories_job_homeView_free_model.dart';
// import 'package:freelancer/models/jobs_list_model.dart';

// class CategoriesJobHomeviewFree extends StatelessWidget {
//   CategoriesJobHomeviewFree({super.key});
//   final ref = FirebaseFirestore.instance.collection('jobs');

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double width = constraints.maxWidth;
//         // final int columns = width > 600
//         //     ? 4
//         //     : width > 400
//         //         ? 3
//         //         : 2;

//         return StreamBuilder<QuerySnapshot>(
//           stream: ref.snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             return Center(
//               child: GridView.count(
//                 crossAxisCount: snapshot.data!.docs.length,
//                 childAspectRatio: 0.8,
//                 physics: ScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
//                 children: List.generate(snapshot.data!.docs.length, (index) {
//                   var post = snapshot.data!.docs[index];
//                   var category = JobsListModel(
//                     description: post["description"],
//                     category: post["category"],
//                     title: post["title"],
//                     happeningDate: post["happening_time"],
//                     enroll_start_time: post["enroll_start_time"],
//                     enroll_end_time: post["enroll_end_time"],
//                     jobID: post["jobID"],
//                     location: post["location"],
//                     skills: post["skills"],
//                     timestamp: post["timestamp"],
//                     salary: post["salary"],
//                     requirement: post["requirement"],
//                     experienceLevel: post["experience"],
//                   );

//                   return GestureDetector(
//                     onTap: () {
//                       // Handle category selection
//                       // For example, navigate to a specific job list page
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(
//                       //       builder: (context) => JobList(
//                       //           category: category.title,
//                       //           // Add other parameters as needed
//                       //           )),
//                       // );
//                     },
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 8),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             width: 65,
//                             height: 65,
//                             child: CircleAvatar(
//                               backgroundImage: NetworkImage(""),
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             category.category,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(color: Colors.black, fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
