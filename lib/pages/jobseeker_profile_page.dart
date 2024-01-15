import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'skills_input.dart'; // Import the newly created file

class JobSeekerProfilePage extends StatefulWidget {
  const JobSeekerProfilePage({Key? key}) : super(key: key);

  @override
  _JobSeekerProfilePageState createState() => _JobSeekerProfilePageState();
}

class _JobSeekerProfilePageState extends State<JobSeekerProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _birthdayController;

  List<Widget> workExperienceWidgets = [];
  List<Widget> educationalAttainmentWidgets = [];

  bool profileCompleted = false;
  late DocumentSnapshot userProfile;

  List<String> skillsList = [];
  List<String> selectedSkills = [];
  List<String>? skillsFromFirestore;
  List<String> filteredSkills = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _birthdayController = TextEditingController();

    fetchUserProfile();
  }

  Future<List<String>> fetchSkills() async {
    try {
      QuerySnapshot skillsSnapshot =
          await FirebaseFirestore.instance.collection('skills').get();
      List<String> skillsList = skillsSnapshot.docs
          .map((doc) => doc['skill_name'] as String)
          .toList();

      // Print the details of retrieved skills
      print('Retrieved skills:');
      skillsList.forEach((skill) {
        print(skill);
      });

      return skillsList;
    } catch (error) {
      print('Error fetching skills: $error');
      return [];
    }
  }

  Future<void> fetchUserProfile() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('jobseeker')
          .doc(userEmail)
          .get();

      setState(() {
        if (userDoc.exists) {
          userProfile = userDoc;
          profileCompleted = userProfile['profileCompleted'] ?? false;

          _firstNameController.text = userProfile['firstName'] ?? '';
          _lastNameController.text = userProfile['lastName'] ?? '';
          _emailController.text = userProfile['email'] ?? '';
          _ageController.text =
              userProfile['age'] != null ? userProfile['age'].toString() : '';
          _birthdayController.text = userProfile['birthday'] != null
              ? userProfile['birthday'].toString()
              : '';

          List<dynamic> skills = userProfile['skills'] ?? [];
          selectedSkills =
              skills.map<String>((skill) => skill.toString()).toList();

          // Set existing work experiences
          List<dynamic> workExperiences = userProfile['workExperiences'] ?? [];
          workExperienceWidgets = workExperiences.map((experience) {
            TextEditingController companyController =
                TextEditingController(text: experience['company']);
            TextEditingController durationController =
                TextEditingController(text: experience['duration']);
            TextEditingController positionController =
                TextEditingController(text: experience['position']);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: companyController,
                  decoration: InputDecoration(labelText: 'Company'),
                ),
                TextFormField(
                  controller: durationController,
                  decoration: InputDecoration(labelText: 'Duration'),
                ),
                TextFormField(
                  controller: positionController,
                  decoration: InputDecoration(labelText: 'Position'),
                ),
                SizedBox(height: 10),
              ],
            );
          }).toList();

          // Set existing educational attainments
          List<dynamic> educationalAttainments =
              userProfile['educationalAttainments'] ?? [];
          educationalAttainmentWidgets =
              educationalAttainments.map((attainment) {
            TextEditingController levelController =
                TextEditingController(text: attainment['level']);
            TextEditingController schoolController =
                TextEditingController(text: attainment['school']);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: levelController,
                  decoration: InputDecoration(labelText: 'Level'),
                ),
                TextFormField(
                  controller: schoolController,
                  decoration: InputDecoration(labelText: 'School'),
                ),
                SizedBox(height: 10),
              ],
            );
          }).toList();
        } else {
          // Set default values if the profile doesn't exist
          _firstNameController.text = '';
          _lastNameController.text = '';
          _emailController.text = '';
          _ageController.text = '';
          _birthdayController.text = '';
          selectedSkills = [];
          workExperienceWidgets = [];
          educationalAttainmentWidgets = [];
        }
      });
    }
  }

  Future<void> updateJobSeekerSkills(List<String> selectedSkills) async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      await FirebaseFirestore.instance
          .collection('jobseeker')
          .doc(userEmail)
          .update({'skills': selectedSkills});

      setState(() {
        this.selectedSkills = selectedSkills;
      });
    }
  }

  void addWorkExperienceField() {
    if (mounted) {
      TextEditingController companyController = TextEditingController();
      TextEditingController durationController = TextEditingController();
      TextEditingController positionController = TextEditingController();

      setState(() {
        workExperienceWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: companyController,
                decoration: InputDecoration(labelText: 'Company'),
              ),
              TextFormField(
                controller: durationController,
                decoration: InputDecoration(labelText: 'Duration'),
              ),
              TextFormField(
                controller: positionController,
                decoration: InputDecoration(labelText: 'Position'),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      });
    }
  }

  void addEducationalAttainmentField() {
    if (mounted) {
      TextEditingController levelController = TextEditingController();
      TextEditingController schoolController = TextEditingController();

      setState(() {
        educationalAttainmentWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: levelController,
                decoration: InputDecoration(labelText: 'Level'),
              ),
              TextFormField(
                controller: schoolController,
                decoration: InputDecoration(labelText: 'School'),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      });
    }
  }

  bool checkProfileCompletion() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
    // Add more validation checks as needed for other fields
    // ...
  }

  Future<void> updateProfile() async {
    String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    if (userEmail.isNotEmpty) {
      // Fetch existing data before updating
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('jobseeker')
          .doc(userEmail)
          .get();

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Update basic profile details
      userData['firstName'] = _firstNameController.text;
      userData['lastName'] = _lastNameController.text;
      userData['email'] = _emailController.text;
      userData['age'] = int.tryParse(_ageController.text) ?? 0;
      userData['birthday'] = _birthdayController.text;

      userData['skills'] = selectedSkills;

      // Update or merge work experiences
      List<Map<String, dynamic>> workExperiences = [];
      for (Widget widget in workExperienceWidgets) {
        TextFormField companyField =
            (widget as Column).children[0] as TextFormField;
        TextFormField durationField =
            (widget as Column).children[1] as TextFormField;
        TextFormField positionField =
            (widget as Column).children[2] as TextFormField;

        workExperiences.add({
          'company': companyField.controller?.text ?? '',
          'duration': durationField.controller?.text ?? '',
          'position': positionField.controller?.text ?? '',
        });
      }
      userData['workExperiences'] = workExperiences;

      // Update or merge educational attainments
      List<Map<String, dynamic>> educationalAttainments = [];
      for (Widget widget in educationalAttainmentWidgets) {
        TextFormField levelField =
            (widget as Column).children[0] as TextFormField;
        TextFormField schoolField =
            (widget as Column).children[1] as TextFormField;

        educationalAttainments.add({
          'level': levelField.controller?.text ?? '',
          'school': schoolField.controller?.text ?? '',
        });
      }
      userData['educationalAttainments'] = educationalAttainments;

      // Update Firestore with merged data
      await FirebaseFirestore.instance
          .collection('jobseeker')
          .doc(userEmail)
          .set(userData); // Use set to overwrite existing data

      // Update profileCompleted status if criteria are met
      bool isProfileComplete = checkProfileCompletion();
      if (isProfileComplete) {
        await FirebaseFirestore.instance
            .collection('jobseeker')
            .doc(userEmail)
            .update({
          'profileCompleted': true,
        });
      }
      // Refresh the UI after saving
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Seeker Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await updateProfile();
              fetchUserProfile();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile Details', style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _birthdayController,
                decoration: InputDecoration(labelText: 'Birthday'),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Skills', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _showSkillsDialog(context);
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                  // Display selected skills here or any other UI representation
                  Wrap(
                    children: selectedSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        onDeleted: () {
                          setState(() {
                            selectedSkills.remove(skill);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Work Experiences', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: addWorkExperienceField,
                        child: Text('Add'),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: workExperienceWidgets,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Educational Attainments',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(
                        width: 30,
                      ),
                      ElevatedButton(
                        onPressed: addEducationalAttainmentField,
                        child: Text('Add'),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: educationalAttainmentWidgets,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkillsDialog(BuildContext context) async {
    print('Fetching skills...'); // Indicate the start of skill fetching

    try {
      List<String> skillsList =
          await fetchSkills(); // Call fetchSkills directly

      print('Retrieved skills:');
      skillsList.forEach((skill) {
        print(skill);
      });

      if (skillsList.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Select Skills'),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    width: double.maxFinite,
                    child: ListView.builder(
                      itemCount: skillsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final skill = skillsList[index];
                        final isSelected = selectedSkills.contains(skill);

                        return CheckboxListTile(
                          title: Text(skill),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null) {
                                if (value) {
                                  selectedSkills.add(skill);
                                } else {
                                  selectedSkills.remove(skill);
                                }
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    updateJobSeekerSkills(selectedSkills);
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      } else {
        print('Skills list is empty');
      }
    } catch (error) {
      print('Error fetching skills: $error');
      // Handle error here according to your app's logic
    }
  }
}
