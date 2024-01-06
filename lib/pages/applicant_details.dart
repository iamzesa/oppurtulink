import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicantDetailsPage extends StatefulWidget {
  final Map<String, dynamic> applicantData;

  const ApplicantDetailsPage({Key? key, required this.applicantData})
      : super(key: key);

  @override
  _ApplicantDetailsPageState createState() => _ApplicantDetailsPageState();
}

class _ApplicantDetailsPageState extends State<ApplicantDetailsPage> {
  TextEditingController _statusController = TextEditingController();
  late String _status;

  @override
  void initState() {
    super.initState();
    // Initialize status with the applicant's current status
    _status = widget.applicantData['status'];
    _statusController.text = _status;
  }

  @override
  Widget build(BuildContext context) {
    print('Applicant Data: ${widget.applicantData}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Applicant Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applicant Name: ${widget.applicantData['profileData']['firstName']} ${widget.applicantData['profileData']['lastName']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Email: ${widget.applicantData['profileData']['email']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Applied On: ${widget.applicantData['submittedAt'].toDate()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Work Experiences:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.applicantData['profileData']['workExperiences']
                  .map<Widget>((experience) {
                return Text(
                  '- ${experience['duration']} at ${experience['company']}, ${experience['position']}',
                  style: TextStyle(fontSize: 14),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            Text(
              'Skills:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              children: widget.applicantData['profileData']['skills']
                  .map<Widget>((skill) {
                return Chip(
                  label: Text(skill),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            Text(
              'Educational Attainment:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.applicantData['profileData']
                      ['educationalAttainments']
                  .map<Widget>((education) {
                return Text(
                  '- ${education['level']} at ${education['school']}',
                  style: TextStyle(fontSize: 14),
                );
              }).toList(),
            ),
            TextFormField(
              controller: _statusController,
              decoration: InputDecoration(
                labelText: 'Status',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateStatus();
              },
              child: Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildProfileData(Map<String, dynamic> profileData) {
    List<Widget> profileWidgets = [];

    profileWidgets.add(
      Text(
        'Profile Data:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );

    profileData.forEach((key, value) {
      profileWidgets.add(
        Text(
          '$key: $value',
          style: TextStyle(fontSize: 16),
        ),
      );
    });

    return profileWidgets;
  }

  void _updateStatus() {
    // Update status in Firestore
    FirebaseFirestore.instance
        .collection('jobApplications')
        .where('applicantId',
            isEqualTo:
                widget.applicantData['applicantId']) // Identify the applicant
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // Update the document with the provided status
        doc.reference.update({'status': _statusController.text}).then((_) {
          setState(() {
            _status = _statusController.text;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status updated')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status')),
          );
        });
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
}
