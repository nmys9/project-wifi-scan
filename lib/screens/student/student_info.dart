import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class StudentInfo extends StatelessWidget{
  const StudentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getStudentData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              Map<String, dynamic> studentData = snapshot.data!;
              return ListView(
                children: [
                  buildInfoRow('Full Name', studentData['full_name']),
                  buildInfoRow('Email', studentData['email']),
                  buildInfoRow('Student ID', studentData['id']),
                  // يمكنك إضافة المزيد من البيانات هنا
                ],
              );
            } else {
              return const Center(child: Text('Student data not found.'));
            }
          },
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value?.toString() ?? 'N/A',
          style: const TextStyle(fontSize: 25),),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> getStudentData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (studentDoc.exists) {
        return studentDoc.data() as Map<String, dynamic>;
      }
    }
    return null;
  }

}