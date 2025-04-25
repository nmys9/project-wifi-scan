import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_wifi_scan/screens/user_type_page.dart';
import '../../widgets/get_doctor_location.dart';
import '/screens/student/student_info.dart';

import '../../widgets/get_user_name.dart';


class HomePageStudent extends StatefulWidget{
  HomePageStudent({super.key});
  static const String id='HomePageStudent';

  @override
  State<HomePageStudent> createState() => _HomePageStudentState();
}

class _HomePageStudentState extends State<HomePageStudent> {
  late Future<String?> _nameFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameFuture=getName();
  }

  void _refreshName(){
    setState(() {
      _nameFuture= getName();
    });
  }

  String formatTimestamp(Timestamp timestamp){
    final dateTime= timestamp.toDate();
    final hour= dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute=dateTime.minute.toString().padLeft(2,'0');
    final period = dateTime.hour >= 12 ? 'مساءاً' : 'صباحاً';

    final day = dateTime.day;
    final monthNames = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final month = monthNames[dateTime.month];

    return 'الساعة $hour:$minute $period , $day $month';
  }

  void logout(BuildContext context)async{
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed(UserType.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page Student'),
        actions: [
          IconButton(
              onPressed: ()=> logout(context),
              icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async{
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=> const StudentInfo(),
                    ),
                  );
                  _refreshName();
                },
                child: FutureBuilder<String?>(
                  future: _nameFuture,
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
                              offset: const Offset(0, 3), // changes position of shadow
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
              FutureBuilder<List<Map<String, dynamic>>> (
                future: getDoctorsLocations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data != null) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width:  double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                snapshot.data![index]['full_name'],
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8,),
                              Text(
                                snapshot.data![index]['location'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8,),
                              if(snapshot.data![index]['timestamp']!=null)
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(text: 'آخر ظهور ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: formatTimestamp(snapshot.data![index]['timestamp'])),
                                    ],
                                  ),
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
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