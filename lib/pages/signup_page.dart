import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oppurtulink/components/my_button.dart';
import 'package:oppurtulink/components/my_textfield.dart';
import 'package:provider/provider.dart';

import '../components/square_tile.dart';
import '../services/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../user_role.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late AuthService authService;

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final positionController = TextEditingController();

  bool areTermsAccepted = false;

  // sign user in method
  void signUserUp() async {
    final role = Provider.of<UserRole>(context, listen: false).role;

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        bool profileCompleted = false;

        //save to employer
        if (role == 'employer') {
          await FirebaseFirestore.instance
              .collection('employer')
              .doc(emailController.text)
              .set({
            'email': emailController.text,
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'companyName': companyNameController.text,
            'position': positionController.text,
            'aboutCompany': 'To be added',
          });

          //save to jobseeker
        } else if (role == 'jobseeker') {
          await FirebaseFirestore.instance
              .collection('jobseeker')
              .doc(emailController.text)
              .set({
            'email': emailController.text,
            'firstName': firstNameController.text,
            'lastName': lastNameController.text,
            'profileCompleted': profileCompleted,
          });
        }

        Navigator.pop(context); // Pop the loading dialog

        showSuccessMessage(
            'Account created successfully! You are automatically logged in!');

        // Delay the navigation for a smoother transition
        Future.delayed(const Duration(seconds: 2), () {
          resetTextFields();
          Navigator.pop(context);
        });
      } else {
        showErrorMessage('Passwords do not match');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Pop the loading dialog
      showErrorMessage(e.code);
    }
  }

  void resetTextFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    companyNameController.clear();
  }

  void showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Success')),
          content: Center(child: Text(message)),
        );
      },
    );
  }

  //error message wrong credentials
  void showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              errorMessage,
            ),
          ),
        );
      },
    );
  }

  Future<String?> fetchTermsAndConditions() async {
    try {
      DocumentSnapshot termsSnapshot = await FirebaseFirestore.instance
          .collection('terms_and_conditions')
          .doc('terms')
          .get();

      String? termsText = termsSnapshot['text'];
      return termsText;
    } catch (e) {
      print('Error fetching terms and conditions: $e');
      return null;
    }
  }

  void _showTermsAndConditionsDialog() {
    fetchTermsAndConditions().then((termsText) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Terms and Conditions'),
            content: SingleChildScrollView(
              child: Text(
                termsText ?? 'Failed to retrieve terms.',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<UserRole>(context, listen: false).role;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // logo
                Image.asset(
                  'lib/images/logo.png',
                  height: 100,
                ),

                // welcome back, you've been missed!
                Text(
                  'Are you a/an',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),
                //radio button for employer and jobseeker

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(
                      value: 'employer',
                      groupValue: Provider.of<UserRole>(context).role,
                      onChanged: (value) {
                        setState(() {
                          Provider.of<UserRole>(context, listen: false)
                              .setRole(value!);
                          print('Role: $value');
                        });
                      },
                    ),
                    const Text('Employer'),
                    Radio<String>(
                      value: 'jobseeker',
                      groupValue: Provider.of<UserRole>(context).role,
                      onChanged: (value) {
                        setState(() {
                          Provider.of<UserRole>(context, listen: false)
                              .setRole(value!);
                          print('Role: $value');
                        });
                      },
                    ),
                    const Text('Jobseeker'),
                  ],
                ),

                //firstname and lastname
                MyTextField(
                  controller: firstNameController,
                  hintText: 'First Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: lastNameController,
                  hintText: 'Last Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                if (role == 'employer')
                  Column(
                    children: [
                      MyTextField(
                        controller: companyNameController,
                        hintText: 'Company Name',
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: positionController,
                        hintText: 'Position',
                        obscureText: false,
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                // email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // sign up button
                MyButton(
                  onTap: signUserUp,
                  buttonText: 'Sign Up',
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: areTermsAccepted,
                      onChanged: (value) {
                        setState(() {
                          areTermsAccepted = value ?? false;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        _showTermsAndConditionsDialog();
                      },
                      child: Text(
                        'I agree to the terms and conditions',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                // const SizedBox(height: 50),
                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // google sign up buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google button for sign-up
                    SquareTile(
                      onTap: areTermsAccepted
                          ? () async {
                              final authService =
                                  AuthService(); // Create an instance of AuthService
                              final role =
                                  Provider.of<UserRole>(context, listen: false)
                                      .role;

                              if (role == null || role.isEmpty) {
                                // Show an error dialog if the role is not selected
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Role Not Selected'),
                                      content: const Text(
                                        'Please select a role (jobseeker or employer) before signing up with Google.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                print('Role from SquareTile 04/04 $role');
                                authService.signUpWithGoogle(role);
                              }
                            }
                          : null,
                      imagePath: 'lib/images/google.png',
                    ),
                    SizedBox(height: 20)
                  ],
                ),

                //
              ],
            ),
          ),
        ),
      ),
    );
  }
}
