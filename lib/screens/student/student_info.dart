import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (studentDoc.exists) {
        setState(() {
          studentData = studentDoc.data() as Map<String, dynamic>?;
        });
      } else {
        setState(() {
          studentData = null;
        });
      }
    } else {
      setState(() {
        studentData = null;
      });
    }
  }

  Widget _buildInfoCard(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Info',style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: studentData == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            _buildInfoCard(
              context,
              'Full Name',
              studentData?['full_name'] ?? 'N/A',
              Icons.person,
            ),
            _buildInfoCard(
              context,
              'Email',
              studentData?['email'] ?? 'N/A',
              Icons.email,
            ),
            _buildInfoCard(
              context,
              'Student ID',
              studentData?['id']?.toString() ?? 'N/A',
              Icons.badge,
            ),
            // يمكنك إضافة المزيد من الحقول هنا لعرض بيانات أخرى
          ],
        ),
      ),
    );
  }
}
