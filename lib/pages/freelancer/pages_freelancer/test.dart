import 'package:flutter/material.dart';


class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Users', 'Jobs', 'Posts'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserManagement(),
          JobManagement(),
          PostManagement(),
        ],
      ),
    );
  }
}

class UserManagement extends StatelessWidget {
  final List<Map<String, dynamic>> users = [
    {'id': 1, 'name': 'Alice Johnson', 'email': 'alice@example.com', 'role': 'Admin', 'status': 'Active'},
    {'id': 2, 'name': 'Bob Smith', 'email': 'bob@example.com', 'role': 'User', 'status': 'Inactive'},
    {'id': 3, 'name': 'Charlie Brown', 'email': 'charlie@example.com', 'role': 'Moderator', 'status': 'Active'},
  ];

   UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      title: 'User Management',
      description: 'Manage user accounts, roles, and permissions.',
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(user['name'][0]),
            ),
            title: Text(user['name']),
            subtitle: Text(user['email']),
            trailing: Chip(
              label: Text(user['status']),
              backgroundColor: user['status'] == 'Active' ? Colors.green : Colors.grey,
            ),
            onTap: () {
              // Show user details or edit screen
            },
          );
        },
      ),
    );
  }
}

class JobManagement extends StatelessWidget {
  final List<Map<String, dynamic>> jobs = [
    {'id': 1, 'title': 'Frontend Developer', 'company': 'Tech Co.', 'applicants': 15, 'status': 'Open'},
    {'id': 2, 'title': 'UX Designer', 'company': 'Design Inc.', 'applicants': 8, 'status': 'Closed'},
    {'id': 3, 'title': 'Data Analyst', 'company': 'Data Corp', 'applicants': 20, 'status': 'Open'},
  ];

   JobManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      title: 'Job Management',
      description: 'Manage job listings and applications.',
      child: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return ListTile(
            title: Text(job['title']),
            subtitle: Text(job['company']),
            trailing: Chip(
              label: Text(job['status']),
              backgroundColor: job['status'] == 'Open' ? Colors.green : Colors.grey,
            ),
            onTap: () {
              // Show job details or edit screen
            },
          );
        },
      ),
    );
  }
}

class PostManagement extends StatelessWidget {
  final List<Map<String, dynamic>> posts = [
    {'id': 1, 'title': 'New Feature Announcement', 'author': 'Alice Johnson', 'comments': 5, 'status': 'Published'},
    {'id': 2, 'title': 'Tips for Job Seekers', 'author': 'Bob Smith', 'comments': 10, 'status': 'Draft'},
    {'id': 3, 'title': 'Industry Trends 2024', 'author': 'Charlie Brown', 'comments': 3, 'status': 'Published'},
  ];

   PostManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementLayout(
      title: 'Post Management',
      description: 'Manage blog posts and articles.',
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post['title']),
            subtitle: Text('By ${post['author']}'),
            trailing: Chip(
              label: Text(post['status']),
              backgroundColor: post['status'] == 'Published' ? Colors.green : Colors.grey,
            ),
            onTap: () {
              // Show post details or edit screen
            },
          );
        },
      ),
    );
  }
}

class ManagementLayout extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const ManagementLayout({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Expanded(child: child),
      ],
    );
  }
}