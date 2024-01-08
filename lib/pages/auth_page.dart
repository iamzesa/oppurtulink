import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oppurtulink/pages/login_page.dart';

import 'home_page.dart';
import 'login_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // user is logged in
        if (snapshot.hasData) {
          String userId = snapshot.data!.uid;

          return HomePage(
            userRole: '',
            userId: userId,
          );
        }
        //user not logged in
        else {
          return LoginPage();
        }
      },
    ));
  }
}
