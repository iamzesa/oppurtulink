import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployerProfilePage extends StatelessWidget {
  const EmployerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('employer')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final employerDocs = snapshot.data?.docs;

          if (employerDocs == null || employerDocs.isEmpty) {
            return const Center(
              child: Text('No employer data found.'),
            );
          }

          final employerData =
              employerDocs.first.data() as Map<String, dynamic>;

          final firstName = employerData['firstName'] as String?;
          final lastName = employerData['lastName'] as String?;
          final companyName = employerData['companyName'] as String?;
          final position = employerData['position'] as String?;
          final email = employerData['email'] as String?;

          print(
              'Position: $position'); // Add this line to check the value of position

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    'lib/images/logo.png',
                    height: 150,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'First Name: $firstName',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Last Name: $lastName',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Company Name: $companyName',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Email: $email',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Position: $position',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
