// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/scan_wifi.dart';
//
// import '../../widgets/get_user_name.dart';
//
// class HomePageDoctor extends StatefulWidget{
//   HomePageDoctor({super.key});
//
//   static const String id='HomePageDoctor';
//
//   @override
//   State<HomePageDoctor> createState() => _HomePageDoctorState();
// }
//
// class _HomePageDoctorState extends State<HomePageDoctor> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('data'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Center(
//           child: ListView(
//             children: [
//               FutureBuilder<Map<String,dynamic>?>(
//                   future: getDoctorLocation(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.hasData && snapshot.data != null) {
//                       setState(() {
//                        Container(
//                         alignment: Alignment.centerRight,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10.0),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: Offset(0, 3), // changes position of shadow
//                             ),
//                           ],
//                           color: Colors.orange,
//                         ),
//                         child: Column(
//                           children: [
//                             Text(
//                               textDirection: TextDirection.rtl,
//                               snapshot.data!['full_name'],
//                               style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               snapshot.data!['location'],
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       );
//                       });
//                     } else {
//                       return const Text('User name not found.');
//                     }
//                     return Container();
//                   },
//                 ),
//
//               const ScanWiFi(),
//             ],
//           ),
//         ),
//       ),
//     );
//
//   }
//
//   Future<Map<String,dynamic>?> getDoctorLocation() async{
//     String doctorId=FirebaseAuth.instance.currentUser!.uid;
//     DocumentSnapshot doctorLocationDoc=
//     await FirebaseFirestore.instance
//         .collection('doctor_locations')
//         .doc(doctorId)
//         .get();
//     if (doctorLocationDoc.exists) {
//       return doctorLocationDoc.data() as Map<String, dynamic>;
//     }
//     return null;
//
//
//   }
// }
//
//
//
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/scan_wifi.dart';
//
// class HomePageDoctor extends StatefulWidget {
//   HomePageDoctor({super.key});
//
//   static const String id = 'HomePageDoctor';
//
//   @override
//   State<HomePageDoctor> createState() => _HomePageDoctorState();
// }
//
// class _HomePageDoctorState extends State<HomePageDoctor> {
//   Map<String, dynamic>? doctorData; // إضافة متغير لتخزين بيانات الدكتور
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('data'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Center(
//           child: ListView(
//             children: [
//               FutureBuilder<Map<String, dynamic>?>(
//                 future: getDoctorLocation(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator();
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if (snapshot.hasData && snapshot.data != null) {
//                     final tempDoctorData = snapshot.data;
//                     // استخدام addPostFrameCallback() لتأجيل setState()
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       setState(() {
//                         doctorData=tempDoctorData;
//                       });
//                     });
//                     return doctorData != null
//                         ? Container(
//                       alignment: Alignment.centerRight,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 2,
//                             blurRadius: 5,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                         color: Colors.orange,
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             doctorData!['full_name'],
//                             style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold),
//                             textDirection: TextDirection.rtl,
//                           ),
//                           Text(
//                             doctorData!['location'],
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     )
//                         : Container(); // إرجاع حاوية فارغة إذا كانت البيانات فارغة
//                   } else {
//                     return const Text('Doctor location not found.');
//                   }
//
//                   return Container();
//
//                 },
//               ),
//               const ScanWiFi(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<Map<String, dynamic>?> getDoctorLocation() async {
//     String doctorId = FirebaseAuth.instance.currentUser!.uid;
//     DocumentSnapshot doctorLocationDoc = await FirebaseFirestore.instance
//         .collection('doctor_locations')
//         .doc(doctorId)
//         .get();
//     if (doctorLocationDoc.exists) {
//       return doctorLocationDoc.data() as Map<String, dynamic>;
//     }
//     return null;
//   }
// }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/scan_wifi.dart';
//
// class HomePageDoctor extends StatefulWidget {
//   HomePageDoctor({super.key});
//
//   static const String id = 'HomePageDoctor';
//
//   @override
//   State<HomePageDoctor> createState() => _HomePageDoctorState();
// }
//
// class _HomePageDoctorState extends State<HomePageDoctor> {
//   // final ValueNotifier<Map<String, dynamic>?> doctorData = ValueNotifier(null);
//   //
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   setState(() {
//   //     fetchDoctorData();
//   //   });
//   //
//   // }
//   //
//   // Future<void> fetchDoctorData() async {
//   //   final docSnapshot = await FirebaseFirestore.instance
//   //       .collection('doctor_locations')
//   //       .doc(FirebaseAuth.instance.currentUser!.uid)
//   //       .get();
//   //
//   //   if (docSnapshot.exists) {
//   //     doctorData.value = docSnapshot.data();
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('data'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Center(
//           child: ListView(
//             children: [
//               StreamBuilder<DocumentSnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('doctor_locations')
//                     .doc(FirebaseAuth.instance.currentUser!.uid)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator(); // 🔄 عرض مؤشر تحميل أثناء جلب البيانات
//                   }
//                   if (!snapshot.hasData || !snapshot.data!.exists) {
//                   return const Text('No data available'); // ❌ إذا لم تكن هناك بيانات
//                   }
//                   final value=snapshot.data!.data() as Map<String,dynamic>;
//
//                   return Container(
//                     alignment: Alignment.centerRight,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10.0),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                       color: Colors.orange,
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           value['full_name'],
//                           style: const TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                           textDirection: TextDirection.rtl,
//                         ),
//                         Text(
//                           value['location'],
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//               const ScanWiFi(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_wifi_scan/scan_wifi.dart';
import 'package:project_wifi_scan/screens/doctor/doctor_info.dart';
import 'package:project_wifi_scan/screens/user_type_page.dart';

class HomePageDoctor extends StatefulWidget {
  HomePageDoctor({super.key});

  static const String id = 'HomePageDoctor';

  @override
  State<HomePageDoctor> createState() => _HomePageDoctorState();
}

class _HomePageDoctorState extends State<HomePageDoctor> {
  late Future<bool> isDoctorFuture;
  Map<String, dynamic>? doctorData;

  @override
  void initState() {
    super.initState();
    isDoctorFuture = checkIfUserIsDoctor();
  }

  Future<bool> checkIfUserIsDoctor() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users') // 🔹 تأكد أن لديك مجموعة users تحتوي على جميع المستخدمين
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (userDoc.exists && userDoc.data()?['role'] == 'doctor') {
      return true;
    } else {
      return false;
    }
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

  void logout(BuildContext) async{
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed(UserType.id);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Data'),
        actions: [
          IconButton(
            onPressed: ()=> logout(context),
            icon: const Icon(
                Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: isDoctorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!) {
            return const Center(child: Text('Access Denied'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () async{
                      final updateData= await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=> const DoctorInfo(),
                        ),
                      );
                      if(updateData != null){
                        setState(() {
                          doctorData=updateData;
                        });
                      }
                    },
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('doctor_locations')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text('No data available');
                        }

                        final value =
                        snapshot.data!.data() as Map<String, dynamic>;

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
                                offset: const Offset(0, 3),
                              ),
                            ],
                            color: Colors.orange,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                value['full_name'],
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textDirection: TextDirection.rtl,
                              ),
                              Text(
                                value['location'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              if(value['timestamp']!=null)
                                Text(
                                  'أخر ظهور ${formatTimestamp(value['timestamp'])}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const ScanWiFi(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
