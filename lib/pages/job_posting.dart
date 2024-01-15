import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostJobPage extends StatefulWidget {
  @override
  _PostJobPageState createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  late User loggedInUser;
  String companyName = '';

  final TextEditingController _jobDetailsController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final List<String> _jobSkills = [];
  final List<String> _requirements = [];

  @override
  void initState() {
    super.initState();
    fetchLoggedInUser();
  }

  void fetchLoggedInUser() {
    loggedInUser = FirebaseAuth.instance.currentUser!;

    FirebaseFirestore.instance
        .collection('employer')
        .doc(loggedInUser.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          companyName = documentSnapshot['companyName'];
        });
      } else {
        print(
            'Document does not exist on Firestore for email: ${loggedInUser.email}');
      }
    }).catchError((error) {
      print('Error retrieving data from Firestore: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a Job'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Company Name: $companyName'),
            SizedBox(height: 10.0),
            Text('Employer Email: ${loggedInUser.email}'),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _jobTitleController,
              decoration: InputDecoration(
                labelText: 'Job Title',
              ),
            ),
            SizedBox(height: 0.0),
            TextFormField(
              controller: _salaryController,
              decoration: InputDecoration(
                labelText: 'Salary',
              ),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _jobDetailsController,
              decoration: InputDecoration(
                labelText: 'Job Details',
              ),
            ),
            SizedBox(height: 10.0),
            _buildSkillsInput(),
            SizedBox(height: 10.0),
            _buildRequirementsInput(),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _postJob(context);
              },
              child: Text('Post Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Job Skills:'),
        Column(
          children: _jobSkills.map((skill) {
            return ListTile(
              title: Text(skill),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            _addSkillDialog(); // Open dialog to add a skill
          },
          child: Text('Add Skill'),
        ),
      ],
    );
  }

  void _addSkillDialog() {
    String newSkill = ''; // To store the entered skill

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Skill'),
          content: TextField(
            onChanged: (value) {
              newSkill = value; // Update newSkill when text changes
            },
            decoration: InputDecoration(
              hintText: 'Enter skill',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog on cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (!_jobSkills.contains(newSkill)) {
                    _jobSkills.add(newSkill);
                  } else {
                    print('Skill $newSkill already exists in _jobSkills');
                  }
                });
                _saveSkillToFirestore(newSkill); // Save skill to Firestore
                Navigator.of(context).pop(); // Close dialog on confirm
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveSkillToFirestore(String skillName) {
    FirebaseFirestore.instance
        .collection('skills')
        .doc(skillName)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Skill $skillName already exists in Firestore');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Skill $skillName already exists'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        FirebaseFirestore.instance.collection('skills').doc(skillName).set({
          'skill_name': skillName,
          // Add more fields or data related to the skill here if needed
        }).then((value) {
          print('Skill $skillName saved to Firestore');
        }).catchError((error) {
          print('Failed to save skill $skillName: $error');
        });
      }
    }).catchError((error) {
      print('Error checking skill $skillName in Firestore: $error');
    });
  }

  Widget _buildRequirementsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Requirements:'),
        Column(
          children: _requirements.map((requirement) {
            return ListTile(
              title: Text(requirement),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            _addRequirementDialog(); // Open dialog to add a requirement
          },
          child: Text('Add Requirement'),
        ),
      ],
    );
  }

  void _addRequirementDialog() {
    String newRequirement = ''; // To store the entered requirement

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Requirement'),
          content: TextField(
            onChanged: (value) {
              newRequirement = value; // Update newRequirement when text changes
            },
            decoration: InputDecoration(
              hintText: 'Enter requirement',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog on cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _requirements
                      .add(newRequirement); // Add requirement to the list
                });
                Navigator.of(context).pop(); // Close dialog on confirm
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _postJob(BuildContext context) {
    String salary = _salaryController.text;
    String jobTitle = _jobTitleController.text;
    String jobDetails = _jobDetailsController.text;
    Timestamp postedDate = Timestamp.now();
    Map<String, dynamic> jobData = {
      'companyName': companyName,
      'employer': loggedInUser.email,
      'jobTitle': jobTitle,
      'salary': salary,
      'jobDetails': jobDetails,
      'postedDate': postedDate,
      'jobSkills': _jobSkills,
      'requirements': _requirements,
    };

    // Save job data to Firestore
    FirebaseFirestore.instance.collection('jobs').add(jobData).then((value) {
      // Job posted successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job posted successfully'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
      _resetForm(); // Reset the form fields

      print('Job posted successfully');
    }).catchError((error) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post job: $error'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
      print('Failed to post job: $error');
    });
  }

  void _resetForm() {
    _jobTitleController.clear();
    _jobDetailsController.clear();
    _jobSkills.clear();
    _requirements.clear();
    _salaryController.clear();

    setState(() {}); // Refresh the UI after clearing the fields
  }
}
