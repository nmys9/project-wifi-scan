import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/student/student_info.dart';

import '../../widgets/get_doctors_name.dart';
import '../../widgets/get_user_name.dart';


class HomePageStudent extends StatelessWidget{
  HomePageStudent({super.key});

  static const String id='HomePageStudent';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ListView(
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=> const StudentInfo(),
                    ),
                  );
                },
                child: FutureBuilder<String?>(
                  future: getName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                          color: Colors.orange,
                        ),
                        child: Text(
                          snapshot.data!,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return const Text('User name not found.');
                    }
                  },
                ),
              ),
              const SizedBox(height: 50),
              FutureBuilder<Map<String,dynamic>?>(
                future: getDoctorLocation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return GridView.builder(
                      gridDelegate:  const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                textDirection: TextDirection.rtl,
                                snapshot.data!['full_name'],
                                style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                              ),
                              Text(
                                snapshot.data!['location'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text('No doctors found.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String,dynamic>?> getDoctorLocation() async{
    String doctorId=FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doctorLocationDoc=
              await FirebaseFirestore.instance
                  .collection('doctor_locations')
                  .doc(doctorId)
                  .get();
    if (doctorLocationDoc.exists) {
      return doctorLocationDoc.data() as Map<String, dynamic>;
    }
    return null;


  }



}
//
//
// return ListView.builder(
// shrinkWrap: true,
// physics: const NeverScrollableScrollPhysics(),
// itemCount: snapshot.data!.length,
// itemBuilder: (context, index) {
// return Container(
// alignment: Alignment.centerRight,
// margin: const EdgeInsets.symmetric(vertical: 8),
// padding: const EdgeInsets.all(16),
// decoration: BoxDecoration(
// boxShadow: [
// BoxShadow(
// color: Colors.grey.withOpacity(0.5),
// spreadRadius: 2,
// blurRadius: 5,
// offset: Offset(0, 3), // changes position of shadow
// ),
// ],
// color: Colors.blue[100],
// borderRadius: BorderRadius.circular(8),
// ),
// child: Column(
// children: [
// Text(
// snapshot.data![index],
// style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
// ),
// Text(
// '**موقع الدكتور**',
// style: const TextStyle(fontSize: 16),
// ),
// ],
// ),
// );
// },
// );