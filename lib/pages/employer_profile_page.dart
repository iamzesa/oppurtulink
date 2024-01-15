import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oppurtulink/pages/edit_employer_profile.dart';

class EmployerProfilePage extends StatefulWidget {
  const EmployerProfilePage({Key? key}) : super(key: key);

  @override
  State<EmployerProfilePage> createState() => _EmployerProfilePageState();
}

class _EmployerProfilePageState extends State<EmployerProfilePage> {
  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('employer')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get()
            .then((snapshot) => snapshot.docs.first),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final parentData = snapshot.data?.data() as Map<String, dynamic>?;

          if (parentData == null) {
            return Center(child: Text('No employer data found.'));
          }

          final firstName = parentData['firstName'] as String?;
          final lastName = parentData['lastName'] as String?;
          final companyName = parentData['companyName'] as String?;
          final email = parentData['email'] as String?;
          final contactNumber = parentData['contactNumber'] as String?;
          final position = parentData['position'] as String?;
          final imageUrl = parentData['userImage'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: imageUrl?.isNotEmpty == true
                      ? NetworkImage(imageUrl!)
                      : AssetImage('lib/images/logo.png') as ImageProvider,
                ),
                SizedBox(height: 16),
                Text(
                  "$firstName $lastName",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "$email",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.business),
                  title: Text(
                    'Company Name:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    companyName ?? '', // Display company name, not email
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    'Position',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    position ?? 'N/A',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(
                    'Contact Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    contactNumber ?? 'N/A',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text('Edit Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
