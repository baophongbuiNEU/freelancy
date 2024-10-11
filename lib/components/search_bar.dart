import 'package:flutter/material.dart';

class SearchBarCompo extends StatelessWidget {
  const SearchBarCompo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Color.fromRGBO(67, 101, 222, 1),
            ),
            Expanded(
              child: TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search service',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon:
                  Icon(Icons.more_vert, color: Color.fromRGBO(67, 101, 222, 1)),
              onPressed: () {
                // Handle menu action here
              },
            ),
          ],
        ),
      ),
    );
  }
}
