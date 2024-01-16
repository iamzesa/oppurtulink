import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'applicant_details.dart';
import 'edit_job.dart';

class ApplicantListPage extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> job;

  const ApplicantListPage({Key? key, required this.job}) : super(key: key);

  @override
  State<ApplicantListPage> createState() => _ApplicantListPageState();
}

class _ApplicantListPageState extends State<ApplicantListPage> {
  @override
  Widget build(BuildContext context) {
    DateTime postedDate = (widget.job['postedDate'] as Timestamp).toDate();
    String formattedDate = DateFormat.yMMMMd().add_jm().format(postedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details & Applicants'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '${widget.job['jobTitle']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditJobDetailsPage(job: widget.job),
                      ),
                    ).then((result) {
                      if (result == true) {
                        setState(() {});
                      }
                    });
                  },
                  child: Text('Edit Details'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Company Name: ${widget.job['companyName']}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Employer: ${widget.job['employer']}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Details: ${widget.job['jobDetails']}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'SkillS Needed: ${widget.job['jobSkills'].join(', ')}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Requirements: ${widget.job['requirements'].join(', ')}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Posted Date: $formattedDate',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'List of Applicants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('jobApplications')
                    .where('jobId', isEqualTo: widget.job.id)
                    .snapshots(),
                builder: (context, applicantSnapshot) {
                  if (applicantSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (applicantSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${applicantSnapshot.error}'));
                  }
                  if (!applicantSnapshot.hasData ||
                      applicantSnapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No applicants available'));
                  }

                  return ListView.builder(
                    itemCount: applicantSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var applicant = applicantSnapshot.data!.docs[index].data()
                          as Map<String, dynamic>;

                      if (applicant.containsKey('applicantId') &&
                          applicant.containsKey('status') &&
                          applicant.containsKey('profileData')) {
                        var profileData =
                            applicant['profileData'] as Map<String, dynamic>;
                        var fullName =
                            '${profileData['firstName']} ${profileData['lastName']}';
                        var status = applicant['status'];

                        return Card(
                          child: ListTile(
                            title: Text(
                              fullName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Text(
                              'Status: $status',
                              style: TextStyle(color: Colors.blue),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ApplicantDetailsPage(
                                      applicantData: applicant),
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return SizedBox(); // Placeholder for no valid applicant data
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
