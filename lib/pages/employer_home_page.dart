import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import 'auth_page.dart';

class EmployerHomePage extends StatelessWidget {
  const EmployerHomePage({Key? key}) : super(key: key);

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              signUserOut(
                  context); // Call signUserOut when IconButton is pressed
            },
            icon: Icon(Icons.logout),
          )
        ],
        title: const Text('Employer Home'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'lib/images/logo.png',
                  height: 150,
                ),
                Container(
                  width: 100, // Adjust the width as needed
                  height: 100, // Adjust the height as needed
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF061cb0),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Navigate to profile page
                    },
                    icon: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTap: () {
                    Navigator.pushNamed(context, '/jobPosting');
                  },
                  buttonText: "Post Job Vacancies",
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                MyButton(
                  onTap: () {
                    Navigator.pushNamed(context, '/jobsList');
                  },
                  buttonText: "Applicants",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
