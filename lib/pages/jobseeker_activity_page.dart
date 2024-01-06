import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class JobSeekerActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Seeker Activity'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobApplications')
            .where('applicantId',
                isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching applications'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No applications found'));
          }

          return Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'List of Job Applications', // Add your text here
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final application = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>?;

                    if (application == null) {
                      return SizedBox(); // Placeholder widget or null if no valid application data
                    }

                    final submittedAt =
                        (application['submittedAt'] as Timestamp?)?.toDate();
                    final daysAgo = submittedAt != null
                        ? _calculateDaysAgo(submittedAt)
                        : 'Unknown';

                    final jobId = application['jobId'] as String?;
                    if (jobId == null) {
                      return SizedBox(); // Handle the case where jobId is null
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(jobId)
                          .get(),
                      builder: (context, jobSnapshot) {
                        if (jobSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
                          return SizedBox(); // Placeholder widget if job details not available
                        }

                        final jobData =
                            jobSnapshot.data!.data() as Map<String, dynamic>;

                        final jobTitle =
                            jobData['jobTitle'] ?? 'Job Title Not Available';
                        final companyName =
                            jobData['companyName'] ?? 'Company Not Available';

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey[200], // Background color
                          ),
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jobTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  companyName,
                                ),
                                Text('Applied $daysAgo days ago'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                viewApplicationStatus(context, application);
                              },
                              child: Text('View Details'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void viewApplicationStatus(
      BuildContext context, Map<String, dynamic> application) {
    final jobId = application['jobId'] as String?;
    if (jobId == null) {
      // Handle the case where jobId is null
      return;
    }

    FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .get()
        .then((jobSnapshot) {
      if (jobSnapshot.exists) {
        final jobData = jobSnapshot.data() as Map<String, dynamic>;
        final jobTitle = jobData['jobTitle'] ?? 'Job Title Not Available';
        final companyName = jobData['companyName'] ?? 'Company Not Available';
        final jobDetails = jobData['jobDetails'] ?? 'Job Details Not Available';
        final jobSkills = (jobData['jobSkills'] as List<dynamic>?) ?? [];
        final jobRequirements =
            (jobData['requirements'] as List<dynamic>?) ?? [];
        final postedDateTimestamp = jobData['postedDate'] as Timestamp?;
        final postedDate = postedDateTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(
                postedDateTimestamp.seconds * 1000)
            : DateTime.now();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Application Details'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Job Title: $jobTitle'),
                  SizedBox(height: 8),
                  Text('Company: $companyName'),
                  SizedBox(height: 8),
                  Text('Job Details: $jobDetails'),
                  SizedBox(height: 8),
                  Text('Job Skills: ${jobSkills.join(', ')}'),
                  SizedBox(height: 8),
                  Text('Job Requirements: ${jobRequirements.join(', ')}'),
                  SizedBox(height: 8),
                  Text(
                      'Posted Date: ${DateFormat.yMMMMd().add_jm().format(postedDate)}'),
                  SizedBox(height: 8),
                  Text(
                      'Application Status: ${application['status'] ?? 'Status Not Available'}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle the case where job details are not found
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Application Details'),
              content: Text('Job details not found'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      // Handle the case where there's an error fetching job details
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Application Details'),
            content: Text('Error fetching job details'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    });
  }

  dynamic _calculateDaysAgo(DateTime submittedAt) {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(submittedAt).inDays;
    return difference;
  }
}
