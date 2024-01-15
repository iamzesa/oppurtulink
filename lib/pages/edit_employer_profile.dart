import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  late String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot employerSnapshot = await FirebaseFirestore.instance
          .collection('employer')
          .doc(firebaseUser.email)
          .get();

      if (employerSnapshot.exists) {
        var employerData = employerSnapshot.data() as Map<String, dynamic>;
        setState(() {
          firstNameController.text = employerData['firstName'] ?? '';
          lastNameController.text = employerData['lastName'] ?? '';
          companyNameController.text = employerData['companyName'] ?? '';
          contactNumberController.text = employerData['contactNumber'] ?? '';
          emailController.text = employerData['email'] ?? '';
          positionController.text = employerData['position'] ?? '';
          _imageUrl = employerData['userImage'] ?? '';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      String userEmail = firebaseUser.email ?? '';
      String firstName = firstNameController.text;
      String lastName = lastNameController.text;
      String companyName = companyNameController.text;
      String email = emailController.text;
      String contactNumber = contactNumberController.text;
      String position = positionController.text;

      CollectionReference employerCollection =
          FirebaseFirestore.instance.collection('employer');

      String imageUrl = _imageUrl;

      if (_imageFile != null) {
        imageUrl = await _uploadImage();
      }

      await employerCollection.doc(userEmail).set({
        'firstName': firstName,
        'lastName': lastName,
        'companyName': companyName,
        'email': email,
        'contactNumber': contactNumber,
        'position': position,
        'userImage': imageUrl,
      });

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context, {
        'firstName': firstName,
        'lastName': lastName,
        'companyName': companyName,
        'email': email,
        'position': position,
        'userImage': imageUrl,
        'contactNumber': contactNumber,
      });
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile != null) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final userId = firebaseUser.email;
        final reference = FirebaseStorage.instance
            .ref()
            .child('users/$userId/profile_image.jpg');
        await reference.putFile(_imageFile!);
        return await reference.getDownloadURL();
      }
    }
    return '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            )
                          : _imageUrl.isNotEmpty
                              ? Image.network(
                                  _imageUrl,
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                )
                              : SizedBox(),
                    ),
                    Icon(Icons.add_a_photo, color: Colors.blueGrey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: companyNameController,
              decoration: InputDecoration(
                labelText: 'Company Name',
                hintText: 'Enter your company name',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: positionController,
              decoration: InputDecoration(
                labelText: 'Position',
                hintText: 'Enter your position',
              ),
            ),
            TextFormField(
              controller: contactNumberController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                hintText: 'Enter your position',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
