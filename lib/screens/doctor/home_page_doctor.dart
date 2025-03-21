import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_wifi_scan/scan_wifi.dart';

import '../../widgets/get_user_name.dart';

class HomePageDoctor extends StatelessWidget{
  HomePageDoctor({super.key});

  static const String id='HomePageDoctor';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ListView(
            children: [
              FutureBuilder<Map<String,dynamic>?>(
                  future: getDoctorLocation(),
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
                    } else {
                      return const Text('User name not found.');
                    }
                  },
                ),

              const ScanWiFi(),
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


