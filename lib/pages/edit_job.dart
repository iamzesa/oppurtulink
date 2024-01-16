import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditJobDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> job;

  const EditJobDetailsPage({Key? key, required this.job}) : super(key: key);

  @override
  _EditJobDetailsPageState createState() => _EditJobDetailsPageState();
}

class _EditJobDetailsPageState extends State<EditJobDetailsPage> {
  late TextEditingController titleController;
  late TextEditingController companyNameController;
  late TextEditingController skillController;
  late TextEditingController reqController;
  List<String> jobSkills = [];
  List<String> requirements = [];
  late TextEditingController jobDetailsController;
  late TextEditingController salaryController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.job['jobTitle']);
    companyNameController =
        TextEditingController(text: widget.job['companyName']);

    jobSkills = (widget.job['jobSkills'] is List<dynamic>)
        ? List<String>.from(widget.job['jobSkills'] as List<dynamic>)
        : [];
    requirements = (widget.job['requirements'] is List<dynamic>)
        ? List<String>.from(widget.job['requirements'] as List<dynamic>)
        : [];

    skillController = TextEditingController();
    reqController = TextEditingController();
    jobDetailsController =
        TextEditingController(text: widget.job['jobDetails']);
    salaryController = TextEditingController(text: widget.job['salary']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Job'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Job Title'),
            ),
            TextField(
              controller: companyNameController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            TextField(
              controller: salaryController,
              decoration: InputDecoration(labelText: 'Salary'),
            ),
            TextField(
              controller: jobDetailsController,
              decoration: InputDecoration(labelText: 'Job Details'),
            ),
            SizedBox(height: 20),
            Text('Job Skills:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Column(
              children: [
                for (var skill in jobSkills)
                  ListTile(
                    title: Text(skill),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          jobSkills.remove(skill);
                        });
                      },
                    ),
                  ),
                ListTile(
                  title: TextField(
                    controller: skillController,
                    decoration: InputDecoration(labelText: 'Add Skill'),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        jobSkills.add(skillController.text);
                        skillController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Requirements:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Column(
              children: [
                for (var req in requirements)
                  ListTile(
                    title: Text(req),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          requirements.remove(req);
                        });
                      },
                    ),
                  ),
                ListTile(
                  title: TextField(
                    controller: reqController,
                    decoration: InputDecoration(labelText: 'Add Requirement'),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        requirements.add(reqController.text);
                        reqController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await _saveChanges();
                print('Save Changes Result: $success');
                if (success) {
                  setState(() {
                    print('Triggering a rebuild in ApplicantListPage');
                  });
                  Navigator.of(context)
                      .pop(true); // Pass true to indicate success
                  print('Navigating back to ApplicantListPage');
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _saveChanges() async {
    try {
      await widget.job.reference.update({
        'jobTitle': titleController.text,
        'companyName': companyNameController.text,
        'jobDetails': jobDetailsController.text,
        'jobSkills': jobSkills,
        'requirements': requirements,
        'salary': salaryController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job updated successfully')),
      );
      return true; // Indicate success
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update job: $error')),
      );
      print('Failed to update job: $error');
      return false; // Indicate failure
    }
  }
}
