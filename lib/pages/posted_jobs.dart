import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oppurtulink/pages/job_posting.dart';
import 'employer_job_details.dart';
import 'job_list_of_applicants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostedJobsPage extends StatefulWidget {
  @override
  _PostedJobsPageState createState() => _PostedJobsPageState();
}

class _PostedJobsPageState extends State<PostedJobsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;
    String? loggedInEmployerEmail;

    if (user != null) {
      loggedInEmployerEmail = user.email;
    } else {
      // Handle the case where the user is not logged in
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Posted Jobs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostJobPage()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Jobs',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: _buildFilteredJobs(loggedInEmployerEmail),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredJobs(String? loggedInEmployerEmail) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jobs')
          .where('employer', isEqualTo: loggedInEmployerEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No jobs available'));
        }

        List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredJobs =
            (snapshot.data!.docs
                    as List<QueryDocumentSnapshot<Map<String, dynamic>>>)
                .where((job) => job['jobTitle']
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();

        return ListView.builder(
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) {
            var job = filteredJobs[index];
            Timestamp postedDate = job['postedDate'];

            // calculate days ago
            DateTime now = DateTime.now();
            DateTime postedDateTime = postedDate.toDate();
            Duration difference = now.difference(postedDateTime);
            int daysAgo = difference.inDays;

            return Container(
              color: Colors.grey[200],
              child: Card(
                child: ListTile(
                  title: Text(
                    job['jobTitle'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${job['companyName']} - $daysAgo days ago'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployerJobDetails(job: job),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(job.id)
                          .delete()
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Job deleted')),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete job')),
                        );
                        print("Failed to delete job: $error");
                      });
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
