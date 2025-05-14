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
  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameFuture=getName();
    _pages = [
      buildScaffoldData(),
      buildScaffoldNotification(),
    ];
    setState(() {});
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
        title: Text(_selectedIndex == 0 ? 'Home Page Student' : "Student Notifications"),
        actions: [
          IconButton(
              onPressed: ()=> logout(context),
              icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items:const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16),
      //   child: Center(
      //     child: ListView(
      //       children: [
      //         GestureDetector(
      //           onTap: () async{
      //             await Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context)=> const StudentInfo(),
      //               ),
      //             );
      //             _refreshName();
      //           },
      //           child: FutureBuilder<String?>(
      //             future: _nameFuture,
      //             builder: (context, snapshot) {
      //               if (snapshot.connectionState == ConnectionState.waiting) {
      //                 return const CircularProgressIndicator();
      //               } else if (snapshot.hasError) {
      //                 return Text('Error: ${snapshot.error}');
      //               } else if (snapshot.hasData && snapshot.data != null) {
      //                 return Container(
      //                   alignment: Alignment.centerRight,
      //                   padding: const EdgeInsets.all(16),
      //                   decoration: BoxDecoration(
      //                     borderRadius: BorderRadius.circular(10.0),
      //                     boxShadow: [
      //                       BoxShadow(
      //                         color: Colors.grey.withOpacity(0.5),
      //                         spreadRadius: 2,
      //                         blurRadius: 5,
      //                         offset: const Offset(0, 3), // changes position of shadow
      //                       ),
      //                     ],
      //                     color: Colors.orange,
      //                   ),
      //                   child: Text(
      //                     snapshot.data!,
      //                     style: const TextStyle(fontSize: 20),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                 );
      //               } else {
      //                 return const Text('User name not found.');
      //               }
      //             },
      //           ),
      //         ),
      //         const SizedBox(height: 50),
      //         StreamBuilder<List<Map<String, dynamic>>> (
      //           stream: getDoctorsLocationsStream(),
      //           builder: (context, snapshot) {
      //             if (snapshot.connectionState == ConnectionState.waiting) {
      //               return const CircularProgressIndicator();
      //             } else if (snapshot.hasError) {
      //               return Text('Error: ${snapshot.error}');
      //             } else if (snapshot.hasData && snapshot.data != null) {
      //               return ListView.builder(
      //                 shrinkWrap: true,
      //                 physics: const NeverScrollableScrollPhysics(),
      //                 itemCount: snapshot.data!.length,
      //                 itemBuilder: (context, index) {
      //                   return Container(
      //                     width:  double.infinity,
      //                     margin: const EdgeInsets.symmetric(vertical: 8),
      //                     padding: const EdgeInsets.all(16),
      //                     decoration: BoxDecoration(
      //                       boxShadow: [
      //                         BoxShadow(
      //                           color: Colors.grey.withOpacity(0.5),
      //                           spreadRadius: 2,
      //                           blurRadius: 5,
      //                           offset: const Offset(0, 3), // changes position of shadow
      //                         ),
      //                       ],
      //                       color: Colors.blue[100],
      //                       borderRadius: BorderRadius.circular(8),
      //                     ),
      //                     child: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.end,
      //                       children: [
      //                         Text(
      //                           snapshot.data![index]['full_name'],
      //                           textDirection: TextDirection.rtl,
      //                           style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
      //                         ),
      //                         const SizedBox(height: 8,),
      //                         Text(
      //                           snapshot.data![index]['location'],
      //                           style: const TextStyle(fontSize: 16),
      //                         ),
      //                         const SizedBox(height: 8,),
      //                         if(snapshot.data![index]['timestamp']!=null)
      //                           Text.rich(
      //                             TextSpan(
      //                               children: [
      //                                 const TextSpan(text: 'آخر ظهور ', style: TextStyle(fontWeight: FontWeight.bold)),
      //                                 TextSpan(text: formatTimestamp(snapshot.data![index]['timestamp'])),
      //                               ],
      //                             ),
      //                             textDirection: TextDirection.rtl,
      //                             style: const TextStyle(fontSize: 14, color: Colors.black54),
      //                           ),
      //                       ],
      //                     ),
      //                   );
      //                 },
      //               );
      //             } else {
      //               return const Text('No doctors found.');
      //             }
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  Padding buildScaffoldData() {
    return Padding(
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
            StreamBuilder<List<Map<String, dynamic>>> (
              stream: getDoctorsLocationsStream(),
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
    );
  }
  Widget buildScaffoldNotification(){
    return   StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final notifications = snapshot.data!.docs;

        if(notifications.isEmpty){
          return Center(child: Text("There is no data"),);
        }

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final data = notifications[index].data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['body'] ?? 'No Body'),
                trailing: Text("${((data['timestamp'])as Timestamp).toDate()}"),
              ),
            );
          },
        );
      },
    );
  }
}

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
// //
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/screens/student/show_all_doctor.dart';
// import 'package:project_wifi_scan/screens/user_type_page.dart';
// import '/screens/student/student_info.dart';
// import '../../widgets/get_user_name.dart';
//
// class HomePageStudent extends StatefulWidget {
//   const HomePageStudent({super.key});
//   static const String id = 'HomePageStudent';
//
//   @override
//   State<HomePageStudent> createState() => _HomePageStudentState();
// }
//
// class _HomePageStudentState extends State<HomePageStudent> {
//   late Future<String?> _nameFuture;
//   TextEditingController _searchController = TextEditingController();
//   String searchText = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _nameFuture = getName();
//     _searchController.addListener(() {
//       setState(() {
//         searchText = _searchController.text;
//       });
//     });
//   }
//
//   void _refreshName() {
//     setState(() {
//       _nameFuture = getName();
//     });
//   }
//
//   String formatTimestamp(Timestamp timestamp) {
//     final dateTime = timestamp.toDate();
//     final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     final period = dateTime.hour >= 12 ? 'مساءاً' : 'صباحاً';
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
//     return 'الساعة $hour:$minute $period , $day $month';
//   }
//
//   void logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.of(context).pushReplacementNamed(UserType.id);
//   }
//
//   // دالة لجلب الدكاترة المفضلين للطالب من جدول users
//   // نفترض أن الطالب لديه حقل favoriteDoctors (List<String>) الذي يحتوي على معرفات الدكاترة.
//   Stream<QuerySnapshot> streamFavoriteDoctors() {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       return FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .snapshots()
//           .asyncExpand((docSnapshot) async* {
//         final data = docSnapshot.data();
//         if (data == null) {
//           yield* const Stream.empty();
//           return;
//         }
//         List<dynamic> favList = data['favoriteDoctors'] ?? [];
//         if (favList.isEmpty) {
//           yield* const Stream.empty();
//         } else {
//           final snapshot = await FirebaseFirestore.instance
//               .collection('doctor_locations')
//               .where(FieldPath.documentId, whereIn: favList)
//               .get();
//           yield snapshot;
//         }
//       });
//     } else {
//       return const Stream.empty();
//     }
//   }
//
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
//               // عرض اسم الطالب
//               GestureDetector(
//                 onTap: () async {
//                   await Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const StudentInfo(),
//                     ),
//                   );
//                   _refreshName();
//                 },
//                 child: FutureBuilder<String?>(
//                   future: _nameFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     } else if (snapshot.hasError) {
//                       return Text('Error: ${snapshot.error}');
//                     } else if (snapshot.hasData && snapshot.data != null) {
//                       return Container(
//                         alignment: Alignment.centerRight,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10.0),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.5),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                           color: Colors.orange,
//                         ),
//                         child: Text(
//                           snapshot.data!,
//                           style: const TextStyle(fontSize: 20),
//                           textAlign: TextAlign.center,
//                         ),
//                       );
//                     } else {
//                       return const Text('User name not found.');
//                     }
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // زر لعرض "جميع الدكاترة"
//               ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pushNamed(context,' ShowAllDoctor.id');
//                   // هنا يمكنك تحديد مسار صفحة "جميع الدكاترة" الذي ستقومين بتطويرها في مرحلة لاحقة
//                 },
//                 icon: const Icon(Icons.people),
//                 label: const Text("جميع الدكاترة"),
//               ),
//               const SizedBox(height: 20),
//               // حقل البحث لتصفية الدكاترة في المفضلة
//               TextField(
//                 controller: _searchController,
//                 decoration: const InputDecoration(
//                   labelText: "ابحث عن دكتور...",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.search),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // عرض قائمة الدكاترة المفضلة
//               const Text(
//                 "الدكاترة المفضلين:",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.right,
//               ),
//               const SizedBox(height: 10),
//               StreamBuilder<QuerySnapshot>(
//                 stream: streamFavoriteDoctors(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const CircularProgressIndicator();
//                   } else if (snapshot.hasError) {
//                     return Text("Error: ${snapshot.error}");
//                   } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
//                     return const Text(
//                       "لا يوجد دكاترة مضافين للمفضلة.",
//                       textAlign: TextAlign.center,
//                     );
//                   } else {
//                     final docs = snapshot.data!.docs;
//                     // تصفية الدكاترة بناءً على النص الذي تم البحث عنه:
//                     final filteredDocs = docs.where((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final fullName = data['full_name']?.toString().toLowerCase() ?? "";
//                       return fullName.contains(searchText.toLowerCase());
//                     }).toList();
//
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: filteredDocs.length,
//                       itemBuilder: (context, index) {
//                         final doctorData = filteredDocs[index].data() as Map<String, dynamic>;
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
//                               Text(
//                                 doctorData['full_name'] ?? "",
//                                 textDirection: TextDirection.rtl,
//                                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 doctorData['location'] ?? "",
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                               const SizedBox(height: 8),
//                               if (doctorData['timestamp'] != null)
//                                 Text.rich(
//                                   TextSpan(
//                                     children: [
//                                       const TextSpan(
//                                         text: "آخر ظهور ",
//                                         style: TextStyle(fontWeight: FontWeight.bold),
//                                       ),
//                                       TextSpan(
//                                         text: formatTimestamp(doctorData['timestamp']),
//                                       ),
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
//                   }
//                 },
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
