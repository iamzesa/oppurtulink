import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'job_list_of_applicants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployerActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;
    String? loggedInEmployerEmail;

    if (user != null) {
      loggedInEmployerEmail = user.email;
    } else {
      // Handle the case where the user is not logged in
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Click on the job to view applicants',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobs')
                  .where('employer', isEqualTo: loggedInEmployerEmail)
                  .snapshots(), // Filter jobs by employer's email
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No jobs available'));
                }

                // Display a list of posted jobs
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var job = snapshot.data!.docs[index]
                        as QueryDocumentSnapshot<Map<String, dynamic>>;
                    Timestamp postedDate = job['postedDate'];

                    // Calculate days ago
                    DateTime now = DateTime.now();
                    DateTime postedDateTime = postedDate.toDate();
                    Duration difference = now.difference(postedDateTime);
                    int daysAgo = difference.inDays;

                    return Container(
                      color: Colors.grey[200], // Background color of the card
                      child: Card(
                        child: ListTile(
                          title: Text(
                            job['jobTitle'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle:
                              Text('${job['companyName']} - $daysAgo days ago'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ApplicantListPage(job: job),
                              ),
                            );
                          },
                          // trailing: IconButton(
                          //   icon: Icon(Icons.delete),
                          //   onPressed: () {
                          //     FirebaseFirestore.instance
                          //         .collection('jobs')
                          //         .doc(job.id)
                          //         .delete()
                          //         .then((_) {
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(content: Text('Job deleted')),
                          //       );
                          //     }).catchError((error) {
                          //       // Handle errors if deletion fails
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //             content: Text('Failed to delete job')),
                          //       );
                          //       print("Failed to delete job: $error");
                          //     });
                          //   },
                          // ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
