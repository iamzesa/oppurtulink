import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<void> signInWithGoogle(String? role) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final user = userCredential.user;

        if (user != null) {
          print('Google User Email: ${user.email}');
          print('Google User Display Name: ${user.displayName}');

          // Check if the user's email exists in the specified role collection
          final roleSnapshot = await FirebaseFirestore.instance
              .collection(role!)
              .doc(user.email)
              .get();

          // Check if the user's email exists in the 'employer' collection
          final employerSnapshot = await FirebaseFirestore.instance
              .collection('employer')
              .doc(user.email)
              .get();

          // Check if the user's email exists in the 'jobseeker' collection
          final jobSeekerSnapshot = await FirebaseFirestore.instance
              .collection('jobseeker')
              .doc(user.email)
              .get();

          if (roleSnapshot.exists) {
            print('User found in $role collection. Proceeding with sign-in.');
            // User found in the specified role collection, proceed with sign-in
            print('Google Sign-In successful: ${userCredential.user}');
          } else if (employerSnapshot.exists || jobSeekerSnapshot.exists) {
            print(
                'User found in employer or jobseeker collection but role does not match. Signing out.');
            // User found in other collection, but not in specified role collection, sign out
            await FirebaseAuth.instance.signOut();
          } else {
            print('User not found in any collection. Signing out.');
            // User not found in any collection, sign out
            await FirebaseAuth.instance.signOut();
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error signing in with Google: $e');
      print('Stack Trace: $stackTrace');
      // Handle the error accordingly
    }
  }

  Future<void> signUpWithGoogle(String? role) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        print('Google : ${googleUser}');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        print('Google Sign-In successful: ${userCredential.user}');

        final user = userCredential.user;

        print('Google User: ${user}');

        if (user != null) {
          print('Google User Email: ${user.email}');
          print('Google User Display Name: ${user.displayName}');

          // Save to Firestore based on role
          Map<String, dynamic> userData = {
            'email': user.email,
            'firstName': user.displayName,
            'profileCompleted': false, // Set profileCompleted to false
          };

          if (role == 'employer') {
            print('Recognized role: Employer');
            // Save to employer collection
            await FirebaseFirestore.instance
                .collection('employer')
                .doc(user.email)
                .set(userData);
          } else if (role == 'jobseeker') {
            print('Recognized role: Jobseeker');
            // Save to jobseeker collection
            await FirebaseFirestore.instance
                .collection('jobseeker')
                .doc(user.email)
                .set(userData);
          } else {
            print('Unrecognized role: $role');
            // Handle unrecognized role
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error signing in with Google: $e');
      print('Stack Trace: $stackTrace');
      // Handle the error accordingly
    }
  }

  Future<bool> doesUserExistForRole(String role, String email) async {
    try {
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection(role).doc(email).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<bool> doesUserExistInAuth(String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      return user?.email == email;
    } catch (e) {
      print('Error checking user existence in Firebase Authentication: $e');
      return false;
    }
  }
}

Future<bool> doesUserExistInRoleCollection(String role, String email) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user?.email != email) {
      return false;
    }

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection(role).doc(email).get();

    return userDoc.exists;
  } catch (e) {
    print('Error checking user existence in Firebase and Firestore: $e');
    return false;
  }
}
