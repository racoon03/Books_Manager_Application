import 'package:flutter/material.dart';

class NavbarFooter extends StatelessWidget {
  const NavbarFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue, // Đặt màu nền cho TabBar
      child: const TabBar(
        indicatorColor:
            Colors.white, // Color of the indicator below the active tab
        labelColor: Colors.white, // Color of the active tab text/icon
        unselectedLabelColor:
            Colors.white70, // Color of the inactive tab text/icon
        tabs: [
          Tab(icon: Icon(Icons.book), text: 'Book'),
          Tab(icon: Icon(Icons.group), text: 'Member'),
          Tab(icon: Icon(Icons.credit_card), text: 'Card'),
        ],
      ),
    );
  }
}
