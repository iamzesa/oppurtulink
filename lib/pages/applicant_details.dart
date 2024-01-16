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
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (widget.applicantData['profileData'] != null) ...[
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          widget.applicantData['profileData']['profileImage'] ??
                              'https://pixabay.com/get/gca1fbef539eb537ed9c9a3076bd45d09b02c90faf2f70d71a67c2c55e17aa0d12134af0f5023c6889705a19c7c32c26c_1280.png',
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Name: ${widget.applicantData['profileData']['firstName']} ${widget.applicantData['profileData']['lastName']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Email: ${widget.applicantData['profileData']['email']}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Age: ${widget.applicantData['profileData']['age'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Birthday: ${widget.applicantData['profileData']['birthday'] ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Applied On: ${widget.applicantData['submittedAt']?.toDate() ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Work Experiences:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: widget.applicantData['profileData']
                                    ['workExperiences'] !=
                                null
                            ? widget.applicantData['profileData']
                                    ['workExperiences']
                                .map<Column>((experience) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '- ${experience['duration']} at ${experience['company']}, ${experience['position']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                );
                              }).toList()
                            : [
                                Column(children: [Text('No work experiences')])
                              ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Skills:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        children: widget.applicantData['profileData']
                                    ['skills'] !=
                                null
                            ? widget.applicantData['profileData']['skills']
                                .map<Widget>((skill) {
                                return Chip(
                                  label: Text(skill),
                                );
                              }).toList()
                            : [Text('No skills')],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Educational Attainment:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.applicantData['profileData']
                                    ['educationalAttainments'] !=
                                null
                            ? widget.applicantData['profileData']
                                    ['educationalAttainments']
                                .map<Column>((education) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '- ${education['level']} at ${education['school']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                );
                              }).toList()
                            : [
                                Column(children: [
                                  Text('No educational attainments')
                                ])
                              ],
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
                  )
                ]
              ]),
            ),
          ],
        ),
      ),
    );
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
