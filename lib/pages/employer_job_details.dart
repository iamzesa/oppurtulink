import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'applicant_details.dart';
import 'edit_job.dart';

class EmployerJobDetails extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> job;

  const EmployerJobDetails({Key? key, required this.job}) : super(key: key);

  @override
  State<EmployerJobDetails> createState() => _EmployerJobDetailsState();
}

class _EmployerJobDetailsState extends State<EmployerJobDetails> {
  @override
  Widget build(BuildContext context) {
    DateTime postedDate = (widget.job['postedDate'] as Timestamp).toDate();
    String formattedDate = DateFormat.yMMMMd().add_jm().format(postedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditJobDetailsPage(job: widget.job),
                ),
              ).then((result) {
                if (result == true) {
                  setState(() {});
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildListTile('Job Title', '${widget.job['jobTitle']}'),
            _buildListTile('Company Name', '${widget.job['companyName']}'),
            _buildListTile('Employer', '${widget.job['employer']}'),
            _buildListTile('Details', '${widget.job['jobDetails']}'),
            _buildListTile(
                'Skills Needed', '${widget.job['jobSkills'].join(', ')}'),
            _buildListTile(
                'Requirements', '${widget.job['requirements'].join(', ')}'),
            _buildListTile('Posted Date', formattedDate),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String label, String data) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        data,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
