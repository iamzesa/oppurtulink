import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerDetailsPage extends StatefulWidget {
  final String employerEmail;

  const EmployerDetailsPage({Key? key, required this.employerEmail})
      : super(key: key);

  @override
  State<EmployerDetailsPage> createState() => _EmployerDetailsPageState();
}

class _EmployerDetailsPageState extends State<EmployerDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employer Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('employer')
            .doc(widget.employerEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No employer data found.'));
          }

          var employerData = snapshot.data!.data() as Map<String, dynamic>;

          final firstName = employerData['firstName'] as String?;
          final lastName = employerData['lastName'] as String?;
          final companyName = employerData['companyName'] as String?;
          final email = employerData['email'] as String?;
          final contactNumber = employerData['contactNumber'] as String?;
          final position = employerData['position'] as String?;
          final imageUrl = employerData['userImage'] as String?;
          final aboutCompany = employerData['aboutCompany'] as String?;
          final aboutCompanyText = aboutCompany ?? 'About not available';

          final imageProvider = imageUrl?.isNotEmpty == true
              ? NetworkImage(imageUrl!)
              : AssetImage('lib/images/logo.png') as ImageProvider;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                CircleAvatar(radius: 50, backgroundImage: imageProvider),
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
                SizedBox(height: 15),
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
                    companyName ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
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
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text(
                    'About Company',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    aboutCompanyText,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
