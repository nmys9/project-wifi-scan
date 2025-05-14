import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../doctor/send_notification_page.dart';

class HomePageAssistant extends StatefulWidget{
  HomePageAssistant({super.key});

  static const String id='HomePageAssistant';

  @override
  State<HomePageAssistant> createState() => _HomePageAssistantState();
}

class _HomePageAssistantState extends State<HomePageAssistant> {


  int _selectedIndex = 0;

  List<Widget> _pages = [];




  @override
  void initState() {
    super.initState();
    _pages = [
      buildScaffoldData(),
      buildScaffoldNotification(),
    ];
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_selectedIndex == 0 ? 'Assistant Home' : "Assistant Notifications")),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 ? SizedBox() : FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context)=> SendNotificationPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
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

  Scaffold buildScaffoldData() => Scaffold();
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/screens/login_page.dart';
// import 'package:wifi_scan/wifi_scan.dart';
//
// class HomePageAssistant extends StatefulWidget {
//   const HomePageAssistant({super.key});
//   static const String id = 'HomePageAssistant';
//
//   @override
//   State<HomePageAssistant> createState() => _HomePageAssistantState();
// }
// class _HomePageAssistantState extends State<HomePageAssistant> {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   late Future<bool> isAssistantFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     isAssistantFuture = checkIfUserIsAssistant();
//   }
//
//   Future<bool> checkIfUserIsAssistant() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null){
//       // إدارة حالة عدم تسجيل الدخول
//       return false;
//     }
//     final userDoc = await firestore
//         .collection('users')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .get();
//     return userDoc.exists && userDoc.data()?['role'] == 'assistant';
//   }
//
//   void _showAddDialog(BuildContext context, String initialUserType) {
//     final studentIdController = TextEditingController();
//     final nameController = TextEditingController();
//     final emailController = TextEditingController();
//     // يمكنك إضافة المزيد من البيانات هنا
//     final List<TextEditingController> bssidControllers = [TextEditingController()];
//     String selectedUserType = initialUserType;
//
//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (context, stepState){
//           return AlertDialog(
//             title:const Text('Add User'),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   DropdownButton<String>(
//                     value: selectedUserType,
//                     items: ['Student','Doctor']
//                         .map((value) => DropdownMenuItem(value: value, child: Text(value)))
//                         .toList(),
//                     onChanged: (newValue){
//                       if (newValue !=null){
//                         stepState((){
//                           selectedUserType = newValue;
//                         });
//                       }
//                     },
//                   ),
//                   if (selectedUserType == 'Student') ...[
//                     TextFormField(
//                       controller: studentIdController,
//                       decoration: const InputDecoration(labelText: 'Student ID'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ],
//                   TextFormField(
//                     controller: nameController,
//                     decoration: const InputDecoration(labelText: 'Name'),
//                     maxLength: 50,
//                   ),
//                   TextFormField(
//                       controller: emailController,
//                       decoration: const InputDecoration(labelText: 'Email')
//                   ),
//                   // يمكنك إضافة المزيد من البيانات هنا
//
//                   //فقط إذا كان دكتور نعرض BSSID
//                   if (selectedUserType == 'Doctor') ...[
//                     const SizedBox(height: 10),
//                     const Text('قائمة BSSID الخاصة بالدكتور'),
//                     for (int i = 0; i < bssidControllers.length; i++)
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: bssidControllers[i],
//                               decoration: InputDecoration(labelText: 'BSSID ${i + 1}'),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.remove_circle),
//                             onPressed: (){
//                               stepState(() => bssidControllers.removeAt(i));
//                             },
//                           ),
//                         ],
//                       ),
//                     TextButton(
//                       onPressed: () {
//                         stepState(() => bssidControllers.add(TextEditingController()));
//                       },
//                       child: const Text('Add BSSID'),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed:() async {
//                   final studentId = studentIdController.text.trim();
//                   final name = nameController.text.trim();
//                   final email = emailController.text.trim();
//                   // يمكنك إضافة المزيد من البيانات هنا
//                   if (name.isEmpty || email.isEmpty || !email.contains('@')) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please enter valid information')),
//                     );
//                     return;
//                   }
//
//                   final studentSnapshot = await firestore
//                       .collection('students')
//                       .where('student_id', isEqualTo: studentId)
//                       .get();
//                   if (studentSnapshot.docs.isNotEmpty){
//                     if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
//                     ScaffoldMessenger.of (context)
//                         .showSnackBar(const SnackBar(content: Text('Student ID already exists')),
//                     );
//                     return;
//                   }
//
//                   final collection = firestore
//                       .collection(selectedUserType == 'Student'? 'students': 'doctors');
//                   final data = <String, dynamic> {
//                     if (selectedUserType == 'Student')
//                       'student_id': studentId,
//                     'name': name,
//                     'email': email,
//                     // يمكنك إضافة المزيد من البيانات هنا
//                   };
//
//                   await collection.add(data);
//                   if (!context.mounted) return; // لتحقق من context بأنه صالح (سليم).
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Add'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _showEditDialog(
//       BuildContext context, String userType, String id, Map<String, dynamic> data) {
//     final studentIdController = TextEditingController(text: data['student_id'] ?? '');
//     final nameController = TextEditingController(text: data['name']);
//     final emailController = TextEditingController(text: data['email']);
//     // يمكنك إضافة المزيد من البيانات هنا
//     final List<TextEditingController> bssidControllers = [];
//
//     final wifiList = data['wifi_list']??[];
//     for (var wifi in wifiList){
//       bssidControllers.add(TextEditingController(text: wifi['bssid']));
//     }
//
//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (context, setState){
//           return AlertDialog(
//             title: Text('Edit $userType'),
//             content: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   if (userType == 'Student') ...[
//                     TextFormField(
//                       controller: studentIdController,
//                       decoration: const InputDecoration(labelText: 'Student ID'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ],
//                   TextFormField(
//                       controller: nameController,
//                       decoration: const InputDecoration(labelText: 'Name'),
//                       maxLength: 50
//                   ),
//                   TextFormField(
//                       controller: emailController,
//                       decoration: const InputDecoration(labelText: 'Email')
//                   ),
//                   // يمكنك إضافة المزيد من البيانات هنا
//
//                   if (userType == 'Doctor') ...[
//                     const SizedBox(height: 10),
//                     const Text('BSSID List'),
//                     for (int i = 0;i < bssidControllers.length; i++)
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: bssidControllers[i],
//                               decoration: InputDecoration(labelText: 'BSSID ${i + 1}'),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.remove_circle),
//                             onPressed: () => setState(() => bssidControllers.removeAt(i)),
//                           ),
//                         ],
//                       ),
//                     TextButton(
//                       onPressed: () => setState(() => bssidControllers.add(TextEditingController())),
//                       child: const Text('Add BSSID'),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () async{
//                   final updatedData = {
//                     if (userType == 'Student')
//                       'student_id': studentIdController.text.trim(),
//                     'name': nameController.text.trim(),
//                     'email': emailController.text.trim(),
//                     // يمكنك إضافة المزيد من البيانات هنا
//                   };
//
//                   if (userType == 'Student') {
//                     final newStudentId = studentIdController.text.trim();
//                     final studentSnapshot = await firestore
//                         .collection('students')
//                         .where('student_id', isEqualTo: newStudentId)
//                         .get();
//                     if (studentSnapshot.docs.isNotEmpty && studentSnapshot.docs.first.id !=id) {
//                       if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
//                       ScaffoldMessenger.of(context)
//                           .showSnackBar(const SnackBar(content: Text('Student ID already exists')),
//                       );
//                       return;
//                     }
//                   }
//
//                   await firestore
//                       .collection(userType == 'Student'? 'students': 'doctors')
//                       .doc(id)
//                       .update(updatedData);
//                   if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Save'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildUserDataTable(String userType){
//     return StreamBuilder<QuerySnapshot>(
//       stream: firestore
//           .collection(userType == 'student'? 'students': 'doctors')
//           .orderBy('name')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//         final userDocs = snapshot.data!.docs;
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('List of ${userType == 'Student' ? 'Students': 'Doctors'}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 16,
//                 columns: [
//                   if (userType == 'Student')
//                     const DataColumn(label: Text('Student ID')),
//                   const DataColumn(label: Text('Name')),
//                   const DataColumn(label: Text('Email')),
//                   const DataColumn(label: Text('Actions')),
//                   // يمكنك إضافة المزيد من البيانات هنا
//                 ],
//                 rows: userDocs.map((user) {
//                   final data = user.data() as Map<String, dynamic>;
//                   return DataRow(cells:[
//                     DataCell(Text(data['student_id'] ?? 'Not Available')),
//                     DataCell(Text(data['name'] ?? 'Not Available')),
//                     DataCell(Text(data['email'] ?? 'Not Available')),
//                     //يمكنك إضافة المزيد من البيانات هنا
//                     DataCell(
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit),
//                             onPressed: () => _showEditDialog(context, userType, user.id, data),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete),
//                             onPressed:() {
//                               showDialog(
//                                 context: context,
//                                 builder: (_) => AlertDialog(
//                                   title: const Text('Delete Confirmation'),
//                                   content: const Text('Are you sure you want to delete this user?'),
//                                   actions: [
//                                     TextButton(
//                                       child: const Text('Yes'),
//                                       onPressed: () async {
//                                         await firestore
//                                             .collection(userType == 'Student'? 'students':'doctors')
//                                             .doc(user.id)
//                                             .delete();
//                                         if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
//                                         Navigator.pop(context); //لإغلاق نافذة التأكيد
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: const Text('Cancel'),
//                                       onPressed: () => Navigator.pop(context), //لإغلاق النافذة بدون حذف
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> _detectDoctorsNearby(BuildContext context) async {
//     final scanPermission = await WiFiScan.instance.canStartScan();
//     if (scanPermission != CanStartScan.yes){
//       if (!context.mounted) return; // لتحقق من context بأنه صالح (سليم).
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Permissions are not available to scan networks')),
//       );
//       return;
//     }
//
//     await WiFiScan.instance.startScan();
//     final networks = await WiFiScan.instance.getScannedResults();
//     final scannedBssids =networks.map((e) => e.bssid).toList();
//
//     final doctorsSnapshot = await firestore.collection('doctors').get();
//     if (!context.mounted)return; //لتحقق من context بأنه صالح (سليم).
//
//     final matchedDoctors = <String>[];
//
//     for (var doc in doctorsSnapshot.docs){
//       final data = doc.data() as Map<String,dynamic>?;
//       if (data == null) continue;
//
//       final wifiList = data['wifi_list']as List<dynamic>? ??[];
//       for (var wifi in wifiList){
//         if (wifi is Map<String, dynamic> &&
//             wifi.containsKey('bssid') &&
//             scannedBssids.contains(wifi['bssid'])){
//           matchedDoctors.add(doc.data()['name']);
//           break;
//         }
//       }
//     }
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Doctors Available in the Area'),
//         content: matchedDoctors.isEmpty?
//         const Text('No doctors found connected to nearby wifi networks')
//             :Text(matchedDoctors.join('\n')),
//         actions: [
//           TextButton(
//             child: const Text('Close'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home page Assistant'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_add_alt_1),
//             tooltip: 'Add student',
//             onPressed: () => _showAddDialog(context, 'Student'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.person_add),
//             tooltip: 'Add doctor',
//             onPressed: () => _showAddDialog(context, 'Doctor'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.wifi_find),
//             tooltip: 'Locate Doctors by wifi',
//             onPressed: () => _detectDoctorsNearby(context),
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Loginout',
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (!context.mounted) return;// لتحقق من context بأنه صالح (سليم).
//               Navigator.pushReplacementNamed(context, Login.id);
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<bool>(
//           future: isAssistantFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (!snapshot.hasData || !snapshot.data!){
//               return const Center(child: Text('Access Denied'));
//             }
//
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   _buildUserDataTable('Student'),
//                   const SizedBox(height: 24),
//                   _buildUserDataTable('Doctor'),
//                 ],
//               ),
//             );
//           }
//       ),
//     );
//   }
// }
//


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/screens/login_page.dart';
// import 'package:wifi_scan/wifi_scan.dart';
//
// class HomePageAssistant extends StatefulWidget {
//   const HomePageAssistant({super.key});
//   static const String id = 'HomePageAssistant';
//
//   @override
//   State<HomePageAssistant> createState() => _HomePageAssistantState();
// }
//
// class _HomePageAssistantState extends State<HomePageAssistant> {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   late Future<bool> isAssistantFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     isAssistantFuture = checkIfUserIsAssistant();
//   }
//
//   Future<bool> checkIfUserIsAssistant() async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       return false;
//     }
//     final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
//     return userDoc.exists && userDoc.data()?['role'] == 'assistant';
//   }
//
//   void _showAddDialog(BuildContext context, String initialUserType) {
//     final studentIdController = TextEditingController();
//     final fullNameController = TextEditingController();
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();
//     String selectedUserType = initialUserType;
//
//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (context, stepState) {
//           return AlertDialog(
//             title: const Text('Add User'),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   DropdownButton<String>(
//                     value: selectedUserType,
//                     items: ['Student', 'Doctor']
//                         .map((value) => DropdownMenuItem(value: value, child: Text(value)))
//                         .toList(),
//                     onChanged: (newValue) {
//                       if (newValue != null) {
//                         stepState(() {
//                           selectedUserType = newValue;
//                         });
//                       }
//                     },
//                   ),
//                   if (selectedUserType == 'Student') ...[
//                     TextFormField(
//                       controller: studentIdController,
//                       decoration: const InputDecoration(labelText: 'Student ID'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ],
//                   TextFormField(
//                     controller: fullNameController,
//                     decoration: const InputDecoration(labelText: 'Full Name'),
//                     maxLength: 50,
//                   ),
//                   TextFormField(
//                     controller: emailController,
//                     decoration: const InputDecoration(labelText: 'Email'),
//                   ),
//                   TextFormField(
//                     controller: passwordController,
//                     decoration: const InputDecoration(labelText: 'Password'),
//                     obscureText: true,
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () async {
//                   final studentId = studentIdController.text.trim();
//                   final fullName = fullNameController.text.trim();
//                   final email = emailController.text.trim();
//                   final password = passwordController.text.trim();
//
//                   if (fullName.isEmpty || email.isEmpty || !email.contains('@') || password.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please enter valid information including password')),
//                     );
//                     return;
//                   }
//
//                   final usersCollection = firestore.collection('users');
//
//                   final emailSnapshot = await usersCollection.where('email', isEqualTo: email).get();
//                   if (emailSnapshot.docs.isNotEmpty) {
//                     if (!context.mounted) return;
//                     ScaffoldMessenger.of(context)
//                         .showSnackBar(const SnackBar(content: Text('Email address already exists')),
//                     );
//                     return;
//                   }
//
//                   String? userId;
//                   try {
//                     final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//                       email: email,
//                       password: password,
//                     );
//                     userId = userCredential.user?.uid;
//
//                     if (userId != null) {
//                       final data = <String, dynamic>{
//                         'full_name': fullName,
//                         'email': email,
//                         'role': selectedUserType.toLowerCase(),
//                         'id': userId,
//                       };
//                       await usersCollection.doc(userId).set(data);
//                       if (!context.mounted) return;
//                       Navigator.pop(context);
//                     }
//                   } on FirebaseAuthException catch (e) {
//                     if (!context.mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error creating user: ${e.message}')),
//                     );
//                     if (userId != null) {
//                       await FirebaseAuth.instance.getUser(userId).then((user) => user.delete());
//                     }
//                   }
//                 },
//                 child: const Text('Add'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void _showEditDialog(BuildContext context, String userType, String id, Map<String, dynamic> data) {
//     final studentIdController = TextEditingController(text: data['student_id'] ?? '');
//     final fullNameController = TextEditingController(text: data['full_name']);
//     final emailController = TextEditingController(text: data['email']);
//     final List<TextEditingController> bssidControllers = [];
//
//     final wifiList = data['wifi_list'] ?? [];
//     for (var wifi in wifiList) {
//       if (wifi is Map<String, dynamic> && wifi.containsKey('bssid')) {
//         bssidControllers.add(TextEditingController(text: wifi['bssid']));
//       }
//     }
//
//     showDialog(
//       context: context,
//       builder: (_) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text('Edit $userType'),
//             content: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   if (userType == 'Student') ...[
//                     TextFormField(
//                       controller: studentIdController,
//                       decoration: const InputDecoration(labelText: 'Student ID'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ],
//                   TextFormField(
//                     controller: fullNameController,
//                     decoration: const InputDecoration(labelText: 'Full Name'),
//                     maxLength: 50,
//                   ),
//                   TextFormField(
//                     controller: emailController,
//                     decoration: const InputDecoration(labelText: 'Email'),
//                   ),
//                   if (userType == 'Doctor') ...[
//                     const SizedBox(height: 10),
//                     const Text('Doctor BSSID List'),
//                     for (int i = 0; i < bssidControllers.length; i++)
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               controller: bssidControllers[i],
//                               decoration: InputDecoration(labelText: 'BSSID ${i + 1}'),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.remove_circle),
//                             onPressed: () => setState(() => bssidControllers.removeAt(i)),
//                           ),
//                         ],
//                       ),
//                     TextButton(
//                       onPressed: () => setState(() => bssidControllers.add(TextEditingController())),
//                       child: const Text('Add BSSID'),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () async {
//                   final updatedData = <String, dynamic>{
//                     'full_name': fullNameController.text.trim(),
//                     'email': emailController.text.trim(),
//                   };
//                   if (userType == 'Student') {
//                     updatedData['student_id'] = studentIdController.text.trim();
//                     final studentSnapshot = await firestore
//                         .collection('users')
//                         .where('role', isEqualTo: 'student')
//                         .where('student_id', isEqualTo: studentIdController.text.trim())
//                         .get();
//                     if (studentSnapshot.docs.isNotEmpty && studentSnapshot.docs.first.id != id) {
//                       if (!context.mounted) return;
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Student ID already exists')),
//                       );
//                       return;
//                     }
//                   } else if (userType == 'Doctor') {
//                     final wifiList = bssidControllers
//                         .map((c) => {'bssid': c.text.trim()})
//                         .where((bssid) => (bssid['bssid'] ?? '').toString().isNotEmpty)
//                         .toList();
//                     updatedData['wifi_list'] = wifiList;
//                   }
//
//                   await firestore.collection('users').doc(id).update(updatedData);
//                   if (!context.mounted) return;
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Save'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildUserDataTable(String userType) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: firestore
//           .collection('users')
//           .where('role', isEqualTo: userType.toLowerCase())
//           .orderBy('full_name')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//         final userDocs = snapshot.data!.docs;
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('List of ${userType == 'Student' ? 'Students' : 'Doctors'}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 16,
//                 columns: const [
//                   DataColumn(label: Text('Student ID')), // يبقى الاسم كما هو
//                   DataColumn(label: Text('Full Name')),
//                   DataColumn(label: Text('Email')),
//                   DataColumn(label: Text('Actions')),
//                 ],
//                 rows: userDocs.map((user) {
//                   final data = user.data() as Map<String, dynamic>;
//                   return DataRow(cells: [
//                     DataCell(Text(data['id'] ?? 'Not Available')), // عرض رقم تعريف الطالب من حقل 'id'
//                     DataCell(Text(data['full_name'] ?? 'Not Available')),
//                     DataCell(Text(data['email'] ?? 'Not Available')),
//                     DataCell(
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit),
//                             onPressed: () => _showEditDialog(context, userType, user.id, data),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete),
//                             onPressed: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (_) => AlertDialog(
//                                   title: const Text('Delete Confirmation'),
//                                   content: const Text('Are you sure you want to delete this user?'),
//                                   actions: [
//                                     TextButton(
//                                       child: const Text('Yes'),
//                                       onPressed: () async {
//                                         await firestore.collection('users').doc(user.id).delete();
//                                         if (!context.mounted) return;
//                                         Navigator.pop(context);
//                                       },
//                                     ),
//                                     TextButton(
//                                       child: const Text('Cancel'),
//                                       onPressed: () => Navigator.pop(context),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   Future<void> _detectDoctorsNearby(BuildContext context) async {
//     final scanPermission = await WiFiScan.instance.canStartScan();
//     if (scanPermission != CanStartScan.yes) {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Permissions are not available to scan networks')),
//       );
//       return;
//     }
//
//     await WiFiScan.instance.startScan();
//     final networks = await WiFiScan.instance.getScannedResults();
//     final scannedBssids = networks.map((e) => e.bssid).toList();
//
//     final doctorsSnapshot = await firestore.collection('users').where('role', isEqualTo: 'doctor').get();
//     if (!context.mounted) return;
//
//     final matchedDoctors = <String>[];
//
//     for (var doc in doctorsSnapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>?;
//       if (data == null) continue;
//
//       final wifiList = data['wifi_list'] as List<dynamic>? ?? [];
//       for (var wifi in wifiList) {
//         if (wifi is Map<String, dynamic> &&
//             wifi.containsKey('bssid') &&
//             scannedBssids.contains(wifi['bssid'])) {
//           matchedDoctors.add(data['full_name']);
//           break;
//         }
//       }
//     }
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Doctors Available in the Area'),
//         content: matchedDoctors.isEmpty
//             ? const Text('No doctors found connected to nearby wifi networks')
//             : Text(matchedDoctors.join('\n')),
//         actions: [
//           TextButton(
//             child: const Text('Close'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home page Assistant'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person_add_alt_1),
//             tooltip: 'Add student',
//             onPressed: () => _showAddDialog(context, 'student'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.person_add),
//             tooltip: 'Add doctor',
//             onPressed: () => _showAddDialog(context, 'doctor'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.wifi_find),
//             tooltip: 'Locate Doctors by wifi',
//             onPressed: () => _detectDoctorsNearby(context),
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (!context.mounted) return;
//               Navigator.pushReplacementNamed(context, Login.id);
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<bool>(
//         future: isAssistantFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || !snapshot.data!) {
//             return const Center(child: Text('Access Denied'));
//           }
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _buildUserDataTable('Student'),
//                 const SizedBox(height: 24),
//                 _buildUserDataTable('Doctor'),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// extension on FirebaseAuth {
//   getUser(String userId) {}
// }
//
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:project_wifi_scan/screens/login_page.dart';
// // import 'package:wifi_scan/wifi_scan.dart';
// //
// // class HomePageAssistant extends StatefulWidget {
// //   const HomePageAssistant({super.key});
// //   static const String id = 'HomePageAssistant';
// //
// //   @override
// //   State<HomePageAssistant> createState() => _HomePageAssistantState();
// // }
// // class _HomePageAssistantState extends State<HomePageAssistant> {
// //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
// //   late Future<bool> isAssistantFuture;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     isAssistantFuture = checkIfUserIsAssistant();
// //   }
// //
// //   Future<bool> checkIfUserIsAssistant() async {
// //     final currentUser = FirebaseAuth.instance.currentUser;
// //     if (currentUser == null){
// //       // إدارة حالة عدم تسجيل الدخول
// //       return false;
// //     }
// //     final userDoc = await firestore
// //         .collection('users')
// //         .doc(FirebaseAuth.instance.currentUser!.uid)
// //         .get();
// //     return userDoc.exists && userDoc.data()?['role'] == 'assistant';
// //   }
// //
// //   void _showAddDialog(BuildContext context, String initialUserType) {
// //     final studentIdController = TextEditingController();
// //     final nameController = TextEditingController();
// //     final emailController = TextEditingController();
// //     // يمكنك إضافة المزيد من البيانات هنا
// //     final List<TextEditingController> bssidControllers = [TextEditingController()];
// //     String selectedUserType = initialUserType;
// //
// //     showDialog(
// //       context: context,
// //       builder: (_) => StatefulBuilder(
// //         builder: (context, stepState){
// //           return AlertDialog(
// //             title:const Text('Add User'),
// //             content: SingleChildScrollView(
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   DropdownButton<String>(
// //                     value: selectedUserType,
// //                     items: ['Student','Doctor']
// //                         .map((value) => DropdownMenuItem(value: value, child: Text(value)))
// //                         .toList(),
// //                     onChanged: (newValue){
// //                       if (newValue !=null){
// //                         stepState((){
// //                           selectedUserType = newValue;
// //                         });
// //                       }
// //                     },
// //                   ),
// //                   if (selectedUserType == 'Student') ...[
// //                     TextFormField(
// //                       controller: studentIdController,
// //                       decoration: const InputDecoration(labelText: 'Student ID'),
// //                       keyboardType: TextInputType.number,
// //                     ),
// //                   ],
// //                   TextFormField(
// //                     controller: nameController,
// //                     decoration: const InputDecoration(labelText: 'Name'),
// //                     maxLength: 50,
// //                   ),
// //                   TextFormField(
// //                       controller: emailController,
// //                       decoration: const InputDecoration(labelText: 'Email')
// //                   ),
// //                   // يمكنك إضافة المزيد من البيانات هنا
// //
// //                   //فقط إذا كان دكتور نعرض BSSID
// //                   if (selectedUserType == 'Doctor') ...[
// //                     const SizedBox(height: 10),
// //                     const Text('قائمة BSSID الخاصة بالدكتور'),
// //                     for (int i = 0; i < bssidControllers.length; i++)
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: bssidControllers[i],
// //                               decoration: InputDecoration(labelText: 'BSSID ${i + 1}'),
// //                             ),
// //                           ),
// //                           IconButton(
// //                             icon: const Icon(Icons.remove_circle),
// //                             onPressed: (){
// //                               stepState(() => bssidControllers.removeAt(i));
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                     TextButton(
// //                       onPressed: () {
// //                         stepState(() => bssidControllers.add(TextEditingController()));
// //                       },
// //                       child: const Text('Add BSSID'),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed:() async {
// //                   final studentId = studentIdController.text.trim();
// //                   final name = nameController.text.trim();
// //                   final email = emailController.text.trim();
// //                   // يمكنك إضافة المزيد من البيانات هنا
// //                   if (name.isEmpty || email.isEmpty || !email.contains('@')) {
// //                     ScaffoldMessenger.of(context).showSnackBar(
// //                       const SnackBar(content: Text('Please enter valid information')),
// //                     );
// //                     return;
// //                   }
// //
// //                   final studentSnapshot = await firestore
// //                       .collection('students')
// //                       .where('student_id', isEqualTo: studentId)
// //                       .get();
// //                   if (studentSnapshot.docs.isNotEmpty){
// //                     if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
// //                     ScaffoldMessenger.of (context)
// //                         .showSnackBar(const SnackBar(content: Text('Student ID already exists')),
// //                     );
// //                     return;
// //                   }
// //
// //                   final collection = firestore
// //                       .collection(selectedUserType == 'Students'? 'students': 'doctors');
// //                   final data = <String, dynamic> {
// //                     if (selectedUserType == 'Student')
// //                       'student_id': studentId,
// //                     'name': name,
// //                     'email': email,
// //                     // يمكنك إضافة المزيد من البيانات هنا
// //                   };
// //
// //                   if (selectedUserType == 'Doctor'){
// //                     final wifiList = bssidControllers
// //                         .map((c) => {'bssid': c.text.trim()})
// //                         .where((e) => (e['bssid']?? '').toString().isNotEmpty)
// //                         .toList();
// //                     data['wifi_list'] = wifiList;
// //                   }
// //
// //                   await collection.add(data);
// //                   if (!context.mounted) return; // لتحقق من context بأنه صالح (سليم).
// //                   Navigator.pop(context);
// //                 },
// //                 child: const Text('Add'),
// //               ),
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context),
// //                 child: const Text('Cancel'),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   void _showEditDialog(
// //       BuildContext context, String userType, String id, Map<String, dynamic> data) {
// //     final studentIdController = TextEditingController(text: data['student_id'] ?? '');
// //     final nameController = TextEditingController(text: data['name']);
// //     final emailController = TextEditingController(text: data['email']);
// //     // يمكنك إضافة المزيد من البيانات هنا
// //     final List<TextEditingController> bssidControllers = [];
// //
// //     final wifiList = data['wifi_list']??[];
// //     for (var wifi in wifiList){
// //       bssidControllers.add(TextEditingController(text: wifi['bssid']));
// //     }
// //
// //     showDialog(
// //       context: context,
// //       builder: (_) => StatefulBuilder(
// //         builder: (context, setState){
// //           return AlertDialog(
// //             title: Text('Edit $userType'),
// //             content: SingleChildScrollView(
// //               child: Column(
// //                 children: [
// //                   if (userType == 'Student') ...[
// //                     TextFormField(
// //                       controller: studentIdController,
// //                       decoration: const InputDecoration(labelText: 'Student ID'),
// //                       keyboardType: TextInputType.number,
// //                     ),
// //                   ],
// //                   TextFormField(
// //                       controller: nameController,
// //                       decoration: const InputDecoration(labelText: 'Name'),
// //                       maxLength: 50
// //                   ),
// //                   TextFormField(
// //                       controller: emailController,
// //                       decoration: const InputDecoration(labelText: 'Email')
// //                   ),
// //                   // يمكنك إضافة المزيد من البيانات هنا
// //
// //                   if (userType == 'Doctor') ...[
// //                     const SizedBox(height: 10),
// //                     const Text('BSSID List'),
// //                     for (int i = 0;i < bssidControllers.length; i++)
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: TextFormField(
// //                               controller: bssidControllers[i],
// //                               decoration: InputDecoration(labelText: 'BSSID ${i + 1}'),
// //                             ),
// //                           ),
// //                           IconButton(
// //                             icon: const Icon(Icons.remove_circle),
// //                             onPressed: () => setState(() => bssidControllers.removeAt(i)),
// //                           ),
// //                         ],
// //                       ),
// //                     TextButton(
// //                       onPressed: () => setState(() => bssidControllers.add(TextEditingController())),
// //                       child: const Text('Add BSSID'),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () async{
// //                   final updatedData = {
// //                     if (userType == 'Student')
// //                       'student_id': studentIdController.text.trim(),
// //                     'name': nameController.text.trim(),
// //                     'email': emailController.text.trim(),
// //                     // يمكنك إضافة المزيد من البيانات هنا
// //                   };
// //
// //                   if (userType == 'Student') {
// //                     final newStudentId = studentIdController.text.trim();
// //                     final studentSnapshot = await firestore
// //                         .collection('students')
// //                         .where('student_id', isEqualTo: newStudentId)
// //                         .get();
// //                     if (studentSnapshot.docs.isNotEmpty && studentSnapshot.docs.first.id !=id) {
// //                       if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
// //                       ScaffoldMessenger.of(context)
// //                           .showSnackBar(const SnackBar(content: Text('Student ID already exists')),
// //                       );
// //                       return;
// //                     }
// //                   }
// //
// //                   if (userType == 'Doctor') {
// //                     final  wifiList = bssidControllers
// //                         .map((c) => {'bssid': c.text.trim()})
// //                         .where((bssid) => (bssid['bssid'] ?? '').toString().isNotEmpty)
// //                         .toList();
// //                     data['wifi_list'] = wifiList;
// //                   }
// //
// //                   await firestore
// //                       .collection(userType == 'Student'? 'students': 'doctors')
// //                       .doc(id)
// //                       .update(updatedData);
// //                   if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
// //                   Navigator.pop(context);
// //                 },
// //                 child: const Text('Save'),
// //               ),
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context),
// //                 child: const Text('Cancel'),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildUserDataTable(String userType) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: firestore
// //           .collection('users')
// //           .where('role', isEqualTo: userType.toLowerCase()) // استخدام where لتصفية حسب الدور
// //           .orderBy('name')
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
// //         final userDocs = snapshot.data!.docs;
// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('List of ${userType == 'Student' ? 'Students' : 'Doctors'}',
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 10),
// //             SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               child: DataTable(
// //                 columnSpacing: 16,
// //                 columns: const [
// //                   DataColumn(label: Text('Student ID')),
// //                   DataColumn(label: Text('Name')),
// //                   DataColumn(label: Text('Email')),
// //                   DataColumn(label: Text('Actions')),
// //                 ],
// //                 rows: userDocs.map((user) {
// //                   final data = user.data() as Map<String, dynamic>;
// //                   return DataRow(cells: [
// //                     DataCell(Text(data['student_id'] ?? 'Not Available')),
// //                     DataCell(Text(data['name'] ?? 'Not Available')),
// //                     DataCell(Text(data['email'] ?? 'Not Available')),
// //                     DataCell(
// //                       Row(
// //                         children: [
// //                           IconButton(
// //                             icon: const Icon(Icons.edit),
// //                             onPressed: () => _showEditDialog(context, userType, user.id, data),
// //                           ),
// //                           IconButton(
// //                             icon: const Icon(Icons.delete),
// //                             onPressed: () {
// //                               showDialog(
// //                                 context: context,
// //                                 builder: (_) => AlertDialog(
// //                                   title: const Text('Delete Confirmation'),
// //                                   content: const Text('Are you sure you want to delete this user?'),
// //                                   actions: [
// //                                     TextButton(
// //                                       child: const Text('Yes'),
// //                                       onPressed: () async {
// //                                         await firestore.collection('users').doc(user.id).delete();
// //                                         if (!context.mounted) return;
// //                                         Navigator.pop(context);
// //                                       },
// //                                     ),
// //                                     TextButton(
// //                                       child: const Text('Cancel'),
// //                                       onPressed: () => Navigator.pop(context),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ]);
// //                 }).toList(),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //   Future<void> _detectDoctorsNearby(BuildContext context) async {
// //     final scanPermission = await WiFiScan.instance.canStartScan();
// //     if (scanPermission != CanStartScan.yes){
// //       if (!context.mounted) return; // لتحقق من context بأنه صالح (سليم).
// //       ScaffoldMessenger.of(context)
// //           .showSnackBar(const SnackBar(content: Text('Permissions are not available to scan networks')),
// //       );
// //       return;
// //     }
// //
// //     await WiFiScan.instance.startScan();
// //     final networks = await WiFiScan.instance.getScannedResults();
// //     final scannedBssids =networks.map((e) => e.bssid).toList();
// //
// //     final doctorsSnapshot = await firestore.collection('doctors').get();
// //     if (!context.mounted)return; //لتحقق من context بأنه صالح (سليم).
// //
// //     final matchedDoctors = <String>[];
// //
// //     for (var doc in doctorsSnapshot.docs){
// //       final data = doc.data() as Map<String,dynamic>?;
// //       if (data == null) continue;
// //
// //       final wifiList = data['wifi_list']as List<dynamic>? ??[];
// //       for (var wifi in wifiList){
// //         if (wifi is Map<String, dynamic> &&
// //             wifi.containsKey('bssid') &&
// //             scannedBssids.contains(wifi['bssid'])){
// //           matchedDoctors.add(doc.data()['name']);
// //           break;
// //         }
// //       }
// //     }
// //
// //     showDialog(
// //       context: context,
// //       builder: (_) => AlertDialog(
// //         title: const Text('Doctors Available in the Area'),
// //         content: matchedDoctors.isEmpty?
// //         const Text('No doctors found connected to nearby wifi networks')
// //             :Text(matchedDoctors.join('\n')),
// //         actions: [
// //           TextButton(
// //             child: const Text('Close'),
// //             onPressed: () => Navigator.pop(context),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context){
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Home page Assistant'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.person_add_alt_1),
// //             tooltip: 'Add student',
// //             onPressed: () => _showAddDialog(context, 'student'),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.person_add),
// //             tooltip: 'Add doctor',
// //             onPressed: () => _showAddDialog(context, 'doctor'),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.wifi_find),
// //             tooltip: 'Locate Doctors by wifi',
// //             onPressed: () => _detectDoctorsNearby(context),
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             tooltip: 'Loginout',
// //             onPressed: () async {
// //               await FirebaseAuth.instance.signOut();
// //               if (!context.mounted) return;// لتحقق من context بأنه صالح (سليم).
// //               Navigator.pushReplacementNamed(context, Login.id);
// //             },
// //           ),
// //         ],
// //       ),
// //       body: FutureBuilder<bool>(
// //           future: isAssistantFuture,
// //           builder: (context, snapshot) {
// //             if (snapshot.connectionState == ConnectionState.waiting) {
// //               return const Center(child: CircularProgressIndicator());
// //             }
// //             if (!snapshot.hasData || !snapshot.data!){
// //               return const Center(child: Text('Access Denied'));
// //             }
// //
// //             return SingleChildScrollView(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 children: [
// //                   _buildUserDataTable('Student'),
// //                   const SizedBox(height: 24),
// //                   _buildUserDataTable('Doctor'),
// //                 ],
// //               ),
// //             );
// //           }
// //       ),
// //     );
// //   }
// // }