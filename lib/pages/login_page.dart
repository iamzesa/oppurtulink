import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oppurtulink/components/my_button.dart';
import 'package:oppurtulink/components/my_textfield.dart';
import 'package:oppurtulink/components/square_tile.dart';
import 'package:oppurtulink/services/auth_services.dart';
import 'package:provider/provider.dart';

import '../user_role.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  final String? userId;

  const LoginPage({super.key, this.userId, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? selectedRole;
  late AuthService authService;
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {
    if (!mounted) return;

    final role = Provider.of<UserRole>(context, listen: false).role;
    final email = emailController.text;

    print('Role: $role');
    print('Email: $email');

    bool userExists = await doesUserExistForRole(role, email);

    if (!userExists) {
      showErrorMessage('User with selected role does not exist');
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      String userId = userCredential.user!.uid;

      navigateToHomePage(context, role, userId);
    } on FirebaseAuthException catch (e) {
      // If the Firebase sign-in fails, display the appropriate error message
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showErrorMessage('Invalid email or password');
      } else {
        showErrorMessage(e.code);
      }
    }
  }

  Future<bool> doesUserExistForRole(String role, String email) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(role) // Use the selected role to access the collection
          .doc(email) // Assume document ID is the email address
          .get();

      return userDoc.exists;
    } catch (e) {
      return false;
    }
  }

  void forgotPassword() async {
    String email = emailController.text;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Password Reset'),
            content: Text('A password reset email has been sent to $email.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error sending password reset email: $e');
      // Show an error message to the user
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content:
                Text('Failed to send password reset email. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void navigateToHomePage(BuildContext context, String role, String userId) {
    if (role == 'employer' || role == 'jobseeker') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userRole: role, userId: userId),
        ),
      );
    } else {
      showErrorMessage('Invalid role selected');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                Image.asset(
                  'lib/images/logo.png',
                  height: 150,
                ),

                const SizedBox(height: 30),

                // welcome back, you've been missed!
                Text(
                  'Are you a/an',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 18,
                  ),
                ),

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

                const SizedBox(height: 25),

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

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: forgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // sign in button
                MyButton(
                  onTap: signUserIn,
                  buttonText: "Log in",
                ),

                const SizedBox(height: 30),

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
                          'Or Sign In With',
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

                // google sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google button
                    SquareTile(
                      onTap: () async {
                        final authService =
                            AuthService(); // Create an instance of AuthService
                        final userRole =
                            Provider.of<UserRole>(context, listen: false).role;

                        if (userRole == null || userRole.isEmpty) {
                          // Show an error dialog if the role is not selected
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Role Not Selected'),
                                content: const Text(
                                  'Please select a role (jobseeker or employer) before signing in with Google.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          authService.signInWithGoogle(userRole);
                        }
                      },
                      imagePath: 'lib/images/google.png',
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF061cb0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}