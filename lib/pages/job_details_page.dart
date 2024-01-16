import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'employer_details.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isChecked = false;

  void initState() {
    super.initState();
    print('Job ID: ${widget.jobId}');
  }

  void _submitApplication() {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      FirebaseFirestore.instance
          .collection('jobseeker')
          .doc(userEmail)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
          FirebaseFirestore.instance.collection('jobApplications').add({
            'applicantId': userEmail,
            'jobId': widget.jobId,
            'profileData': docSnapshot.data(),
            'submittedAt': DateTime.now(),
            'status': 'Pending',
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text('Application Submitted Successfully'),
                  ],
                ),
              ),
            );
            Navigator.of(context).pop();
          }).catchError((error) {
            print('Error submitting application: $error');
          });
        } else {
          print('Job seeker profile not found for the logged-in user');
        }
      }).catchError((error) {
        print('Error fetching job seeker profile: $error');
      });
    } else {
      print('User is not logged in');
      // Handle scenario where the user is not logged in
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error fetching job details'));
          }

          final jobData = snapshot.data!.data();

          if (jobData == null) {
            return Center(child: Text('Job not found'));
          }

          String employerEmail = jobData['employer'];
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('employer')
                .doc(employerEmail)
                .get(),
            builder: (context, employerSnapshot) {
              if (employerSnapshot.connectionState == ConnectionState.waiting ||
                  !employerSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final employerData = employerSnapshot.data!.data();

              if (employerData == null) {
                return Center(child: Text('Employer not found'));
              }

              final companyName = employerData['companyName'];
              final aboutCompany = employerData['aboutCompany'];

              final postedDate =
                  (jobData['datePosted'] as Timestamp?)?.toDate();
              final daysAgo =
                  postedDate != null ? _calculateDaysAgo(postedDate) : 0;

              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  SizedBox(height: 8),
                  // Text(
                  //   'Job Title: ${jobData['jobTitle'] ?? 'Not Available'}',
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: 8),
                  // Text(
                  //   'Company: ${companyName ?? 'Not Available'}',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: 8),
                  // Text(
                  //   'About the Company: ${aboutCompany ?? 'Not Available'}',
                  //   style: TextStyle(fontSize: 12),
                  // ),
                  ListTile(
                    title: Text(
                      '${jobData['jobTitle'] ?? 'Not Available'}',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Company: ${companyName ?? 'Not Available'}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployerDetailsPage(
                              employerEmail: jobData['employer'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text('Employer Details'),
                    ),
                  ),

                  Text(
                    'Salary: ${jobData['salary'] ?? 'Not Available'}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Posted: $daysAgo days ago',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(height: 8),
                  // Container(
                  //   width: 50,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     child: Text('View Employer Details'),
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  Divider(
                    height: 1,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Job Details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(jobData['jobDetails'] ?? 'Job Details Not Available'),
                  SizedBox(height: 8),
                  Text(
                    'Job Skills:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var skill in jobData['jobSkills'] ?? [])
                        Text('• $skill'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Job Requirements:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var requirement in jobData['requirements'] ?? [])
                        Text('• $requirement'),
                    ],
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isChecked ? _submitApplication : null,
                    child: Text('Apply Now'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      Text(
                          'I agree to send my profile details to apply on the job'),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  int _calculateDaysAgo(DateTime postedDate) {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(postedDate);
    return difference.inDays;
  }
}
