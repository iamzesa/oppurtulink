import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oppurtulink/pages/auth_page.dart';
import 'package:oppurtulink/pages/employer_activity_page.dart';
import 'package:oppurtulink/pages/forgot_password.dart';
import 'package:oppurtulink/pages/job_details_page.dart';
import 'package:oppurtulink/pages/job_posting.dart';
import 'package:oppurtulink/pages/posted_jobs.dart';
import 'package:oppurtulink/user_role.dart'; // Import the user_role.dart file
import 'firebase_options.dart';
import 'pages/signup_page.dart';
import 'package:provider/provider.dart'; // Import Provider package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserRole(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Color(0xFF061cb0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFF061cb0)),
            foregroundColor: MaterialStateProperty.all<Color>(
                Colors.white), // Text color set to white
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/signup': (context) => const SignupPage(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/jobDetails': (context) {
          final String jobId =
              ModalRoute.of(context)!.settings.arguments as String;
          return JobDetailsScreen(jobId: jobId);
        },
        '/jobPosting': (context) => PostJobPage(),
        '/jobsList': (context) => EmployerActivityPage(),
        '/postedJobs': (context) => PostedJobsPage()
      },
    );
  }
}
