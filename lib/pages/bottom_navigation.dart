import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_role.dart';
import 'jobseeker_home_page.dart';
import 'jobseeker_activity_page.dart';
import 'jobseeker_profile_page.dart';
import 'employer_home_page.dart';
import 'employer_activity_page.dart';
import 'employer_profile_page.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final String userRole; // Accepting user role as a parameter
  final String userId;

  const MyBottomNavigationBar(
      {Key? key, required this.userRole, required this.userId})
      : super(key: key);

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRole>(context);

    print('User Role in BottomNavigationBar: ${widget.userRole}');

    List<Widget> pages;

    if (userRole.role == 'jobseeker') {
      pages = <Widget>[
        JobSeekerHomePage(),
        JobSeekerActivityPage(),
        JobSeekerProfilePage(),
      ];
    } else {
      pages = <Widget>[
        EmployerHomePage(),
        EmployerActivityPage(),
        EmployerProfilePage(),
      ];
    }

    return Scaffold(
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
