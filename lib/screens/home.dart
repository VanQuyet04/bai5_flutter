import 'package:bai5_flutter/screens/profile_screen.dart';
import 'package:bai5_flutter/screens/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import 'bill_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen>  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    CartPage(),
    BillPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ), // Use BottomNavBar here
    );
  }
}
