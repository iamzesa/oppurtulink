import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_page.dart';

class JobSeekerHomePage extends StatefulWidget {
  const JobSeekerHomePage({super.key});

  @override
  State<JobSeekerHomePage> createState() => _JobSeekerHomePageState();
}

class _JobSeekerHomePageState extends State<JobSeekerHomePage> {
  List<String> jobSeekerSkills = [];
  String welcomeMessage = '';
  List<DocumentSnapshot> recentJobDocs = [];
  List<DocumentSnapshot> allJobs = [];

  final TextEditingController _searchController = TextEditingController();

  late final StreamController<List<DocumentSnapshot>> _filteredJobsController =
      StreamController<List<DocumentSnapshot>>();

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchJobSeekerData();
    fetchAllJobs();
  }

  @override
  void dispose() {
    _filteredJobsController.close();
    super.dispose();
  }

  Future<void> fetchAllJobs() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('jobs').get();
      if (snapshot.docs.isNotEmpty) {
        allJobs = snapshot.docs;
        _filteredJobsController.add(allJobs);
      }
    } catch (error) {
      print('Error fetching all jobs: $error');
    }
  }

  void _filterJobs(String query) {
    if (allJobs.isEmpty) {
      print('All jobs is empty. Fetching jobs...');
      fetchAllJobs().then((_) {
        _applyJobFilter(query);
      });
    } else {
      _applyJobFilter(query);
    }
  }

  void _applyJobFilter(String query) {
    if (query.isNotEmpty) {
      final List<DocumentSnapshot> filteredJobs = allJobs.where((jobDoc) {
        final jobTitle = jobDoc['jobTitle'] as String? ?? '';
        final companyName = jobDoc['companyName'] as String? ?? '';
        final jobSkills = List<String>.from(jobDoc['jobSkills'] ?? []);

        return jobTitle.toLowerCase().contains(query.toLowerCase()) ||
            companyName.toLowerCase().contains(query.toLowerCase()) ||
            jobSkills.any(
                (skill) => skill.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      _filteredJobsController.add(filteredJobs);

      print('Filtered Jobs: $filteredJobs');
    } else {
      _filteredJobsController.add(allJobs);

      print('All Jobs: $allJobs');
    }
  }

  Future<void> fetchJobSeekerData() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      final QuerySnapshot jobSeekerSnapshot = await FirebaseFirestore.instance
          .collection('jobseeker')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (jobSeekerSnapshot.docs.isNotEmpty) {
        final jobSeekerData =
            jobSeekerSnapshot.docs.first.data() as Map<String, dynamic>?;

        if (jobSeekerData != null) {
          final firstName = jobSeekerData['firstName'] as String? ?? '';
          final skills = jobSeekerData['skills'] as List<dynamic>?;

          if (skills != null && skills.isNotEmpty) {
            jobSeekerSkills = skills.whereType<String>().toList();

            print(
                'Retrieved Skills: $jobSeekerSkills'); // Print the retrieved skills

            setState(() {
              // Update the state with the retrieved skills
              jobSeekerSkills = jobSeekerSkills;
              welcomeMessage = 'Welcome, $firstName!';
            });
          } else {
            print('Skills field is empty or not found.');
          }
        } else {
          print('Job seeker data is null.');
        }
      } else {
        print('No jobseeker data found for the user.');
      }
    } else {
      print('User email is null.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: Icon(Icons.logout),
          )
        ],
        title: const Text('Job Seeker Home'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              welcomeMessage,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Find Your Dream Job',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Job search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => _filterJobs(query),
              decoration: InputDecoration(
                hintText: 'Search for jobs...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),

          _buildRecommendedJobs(context),
          _buildRecentJobs(context),
        ],
      ),
    );
  }

  Widget _buildRecommendedJobs(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // if (jobSeekerSkills.isEmpty) {
        //   print('Job Seeker Skills: Empty');
        //   return const Text('No job seeker skills available.');
        // } else {
        //   print('Job Seeker Skills: $jobSeekerSkills');
        // }

        final jobDocs = snapshot.data?.docs ?? [];
        final recommendedJobs = jobDocs.where((jobDoc) {
          final jobSkills = List<String>.from(jobDoc['jobSkills'] ?? []);
          if (jobSkills.isEmpty || jobSeekerSkills.isEmpty) return false;

          // print('Job Skills: $jobSkills');

          final matchingSkills = jobSkills
              .where((skill) => jobSeekerSkills.contains(skill))
              .toList();
          // print('Matching Skills: $matchingSkills');

          return matchingSkills.isNotEmpty;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recommended Jobs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendedJobs.length,
                itemBuilder: (context, index) {
                  final job = recommendedJobs[index];

                  if (job != null && job is DocumentSnapshot) {
                    final jobData = job.data() as Map<String, dynamic>?;

                    if (jobData != null) {
                      final jobTitle = jobData['jobTitle'] as String? ?? '';
                      final companyName =
                          jobData['companyName'] as String? ?? '';

                      return GestureDetector(
                        onTap: () {
                          final jobId = job.id;
                          Navigator.pushNamed(
                            context,
                            '/jobDetails',
                            arguments:
                                jobId, // Pass the document ID as arguments
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color.fromARGB(255, 189, 220, 251),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jobTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(companyName),
                              // Add other job details
                            ],
                          ),
                        ),
                      );
                    }
                  }
                  return Container();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentJobs(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Recent Job Listings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _filteredJobsController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final filteredJobs = snapshot.data ?? [];

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      final jobId = job.id;
                      final jobData = job.data() as Map<String, dynamic>;

                      final postedDate =
                          (jobData['postedDate'] as Timestamp).toDate();
                      final daysAgo = _calculateDaysAgo(postedDate);
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey[200],
                        ),
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(jobData['jobTitle']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(jobData['companyName']),
                              Text('$daysAgo days ago'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/jobDetails',
                                  arguments: jobId);
                            },
                            child: const Text('View'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDaysAgo(DateTime postedDate) {
    final now = DateTime.now();
    final difference = now.difference(postedDate);
    return difference.inDays;
  }
}
