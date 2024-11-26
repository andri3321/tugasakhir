import 'package:flutter/material.dart';
import 'package:tugasakhir/screens/feedback.dart';
import 'package:tugasakhir/screens/konversi.dart';
import 'package:tugasakhir/screens/maps.dart';
import 'package:tugasakhir/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  int _selectedIndex = 0;

  final List _pages = [
    const ConverterPage(),
    MapsPage(), // Add new maps page
    const FeedbackPage(),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: 'Konversi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), // Maps icon
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feedback_outlined),
              label: 'Feedback',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.lightBlue.shade300,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
