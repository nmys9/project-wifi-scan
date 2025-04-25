// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/screens/user_type_page.dart';
// import '../../widgets/get_doctor_location.dart';
// import '/screens/student/student_info.dart';
//
// import '../../widgets/get_user_name.dart';
//
//
// class ShowAllDoctor extends StatefulWidget{
//   ShowAllDoctor({super.key});
//   static const String id='ShowAllDoctor';
//
//   @override
//   State<ShowAllDoctor> createState() => _ShowAllDoctorState();
// }
//
// class _ShowAllDoctorState extends State<ShowAllDoctor> {
//   late Future<String?> _nameFuture;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _nameFuture=getName();
//   }
//
//   void _refreshName(){
//     setState(() {
//       _nameFuture= getName();
//     });
//   }
//
//   String formatTimestamp(Timestamp timestamp){
//     final dateTime= timestamp.toDate();
//     final hour= dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
//     final minute=dateTime.minute.toString().padLeft(2,'0');
//     final period = dateTime.hour >= 12 ? 'مساءاً' : 'صباحاً';
//
//     final day = dateTime.day;
//     final monthNames = [
//       '',
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر'
//     ];
//     final month = monthNames[dateTime.month];
//
//     return 'الساعة $hour:$minute $period , $day $month';
//   }
//
//   void logout(BuildContext context)async{
//     await FirebaseAuth.instance.signOut();
//     Navigator.of(context).pushReplacementNamed(UserType.id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Show All Doctor'),
//         actions: [
//           IconButton(
//               onPressed: ()=> logout(context),
//               icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Center(
//           child: ListView(
//             children: [
//               StreamBuilder<List<Map<String, dynamic>>> (
//                 stream: getDoctorsLocationsStream(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator();
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if (snapshot.hasData && snapshot.data != null) {
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           width:  double.infinity,
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3), // changes position of shadow
//                               ),
//                             ],
//                             color: Colors.blue[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 snapshot.data![index]['full_name'],
//                                 textDirection: TextDirection.rtl,
//                                 style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 8,),
//                               Text(
//                                 snapshot.data![index]['location'],
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                               const SizedBox(height: 8,),
//                               if(snapshot.data![index]['timestamp']!=null)
//                                 Text.rich(
//                                   TextSpan(
//                                     children: [
//                                       const TextSpan(text: 'آخر ظهور ', style: TextStyle(fontWeight: FontWeight.bold)),
//                                       TextSpan(text: formatTimestamp(snapshot.data![index]['timestamp'])),
//                                     ],
//                                   ),
//                                   textDirection: TextDirection.rtl,
//                                   style: const TextStyle(fontSize: 14, color: Colors.black54),
//                                 ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   } else {
//                     return const Text('No doctors found.');
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/screens/user_type_page.dart';
// import '../../widgets/get_doctor_location.dart';
// import '/screens/student/student_info.dart';
//
// import '../../widgets/get_user_name.dart';
//
// class ShowAllDoctor extends StatefulWidget {
//   ShowAllDoctor({super.key});
//   static const String id = 'HomePageStudent';
//
//   @override
//   State<ShowAllDoctor> createState() => _ShowAllDoctorState();
// }
//
// class _ShowAllDoctorState extends State<ShowAllDoctor> {
//   late Future<String?> _nameFuture;
//   List<String> favoriteDoctors = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _nameFuture = getName();
//     _loadFavorites();
//   }
//
//   Future<void> _loadFavorites() async {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     final data = userDoc.data();
//     if (data != null && data['favoriteDoctors'] != null) {
//       setState(() {
//         favoriteDoctors = List<String>.from(data['favoriteDoctors']);
//       });
//     }
//   }
//
//   void _refreshName() {
//     setState(() {
//       _nameFuture = getName();
//     });
//   }
//
//   Future<void> toggleFavorite(String doctorId, bool isCurrentlyFavorite) async {
//     final userDoc = FirebaseFirestore.instance
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid);
//
//     if (isCurrentlyFavorite) {
//       await userDoc.update({
//         'favoriteDoctors': FieldValue.arrayRemove([doctorId])
//       });
//     } else {
//       await userDoc.update({
//         'favoriteDoctors': FieldValue.arrayUnion([doctorId])
//       });
//     }
//
//     await _loadFavorites(); // تحديث المفضلة
//   }
//
//   String formatTimestamp(Timestamp timestamp) {
//     final dateTime = timestamp.toDate();
//     final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     final period = dateTime.hour >= 12 ? 'مساءاً' : 'صباحاً';
//
//     final day = dateTime.day;
//     final monthNames = [
//       '',
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر'
//     ];
//     final month = monthNames[dateTime.month];
//
//     return 'الساعة $hour:$minute $period , $day $month';
//   }
//
//   void logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.of(context).pushReplacementNamed(UserType.id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Page Student'),
//         actions: [
//           IconButton(
//             onPressed: () => logout(context),
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Center(
//           child: ListView(
//             children: [
//               StreamBuilder<List<Map<String, dynamic>>>(
//                 stream: getDoctorsLocationsStream(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator();
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if (snapshot.hasData && snapshot.data != null) {
//                     final doctors = snapshot.data!;
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: doctors.length,
//                       itemBuilder: (context, index) {
//                         final doctor = doctors[index];
//                         final doctorId = doctor['id'] ?? '';
//                         final isFavorite = favoriteDoctors.contains(doctorId);
//
//                         return Container(
//                           width: double.infinity,
//                           margin: const EdgeInsets.symmetric(vertical: 8),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.5),
//                                 spreadRadius: 2,
//                                 blurRadius: 5,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             color: Colors.blue[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   IconButton(
//                                     icon: Icon(
//                                       isFavorite ? Icons.favorite : Icons.favorite_border,
//                                       color: isFavorite ? Colors.red : Colors.grey,
//                                     ),
//                                     onPressed: () async {
//                                       await toggleFavorite(doctorId, isFavorite);
//                                     },
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       doctor['full_name'],
//                                       textDirection: TextDirection.rtl,
//                                       style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                                       textAlign: TextAlign.end,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 doctor['location'],
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               if (doctor['timestamp'] != null)
//                                 Text.rich(
//                                   TextSpan(
//                                     children: [
//                                       const TextSpan(
//                                           text: 'آخر ظهور ',
//                                           style: TextStyle(fontWeight: FontWeight.bold)),
//                                       TextSpan(text: formatTimestamp(doctor['timestamp'])),
//                                     ],
//                                   ),
//                                   textDirection: TextDirection.rtl,
//                                   style: const TextStyle(fontSize: 14, color: Colors.black54),
//                                 ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   } else {
//                     return const Text('No doctors found.');
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
