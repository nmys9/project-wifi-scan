import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_wifi_scan/screens/user_type_page.dart';
import '../../services/firestore.dart';
import '../../widgets/show_snack_bar.dart';
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
  void logout(BuildContext context)async{
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed(UserType.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Assistant Home' : "Assistant Notifications"),
        actions: [
          IconButton(
            onPressed: ()=> logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
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

  final TextEditingController textFullNameController= TextEditingController();
  final TextEditingController textIdController= TextEditingController();
  final TextEditingController textEmailController= TextEditingController();
  final TextEditingController textPasswordController= TextEditingController();
  String? selectRole;
  bool resetPassword=false;
  final FirestoreService firestoreService=FirestoreService();

  void openNotBox(){
    showDialog(
      context: context,
      builder: (context)=> AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Full Name',
                style: TextStyle(
                  fontWeight:  FontWeight.bold,
                ),
              ),
              TextField(
                controller: textFullNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8,),
              const Text('ID',
                style: TextStyle(
                  fontWeight:  FontWeight.bold,
                ),
              ),
              TextField(
                controller: textIdController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8,),
              const Text('Email',
                style: TextStyle(
                  fontWeight:  FontWeight.bold,
                ),
              ),
              TextField(
                controller: textEmailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8,),
              const Text('Password',
                style: TextStyle(
                  fontWeight:  FontWeight.bold,
                ),
              ),
              TextField(
                controller: textPasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8,),
              const Text('Role',
                style: TextStyle(
                  fontWeight:  FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Select role',
                  border: OutlineInputBorder(),
                ),
                value: selectRole,
                items: const[
                  DropdownMenuItem(child: Text('Student'),value: 'student',),
                  DropdownMenuItem(child: Text('doctor'),value: 'doctor',),
                ],
                onChanged: (String? newValue){
                  selectRole=newValue;
                },
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: (){
              if(selectRole != null){
                firestoreService.addUser(
                    full_name:textFullNameController.text,
                    id:textIdController.text,
                    email:textEmailController.text,
                    password: textPasswordController.text,
                    role:selectRole!
                );
                textFullNameController.clear();
                textEmailController.clear();
                textIdController.clear();
                selectRole=null;
                Navigator.pop(context);
              }else{
                showSnackBar(context,'Please select a role');
              }

            },
            child: Text('Add User'),
          ),
          TextButton(
            onPressed: () {
              textFullNameController.clear();
              textEmailController.clear();
              textIdController.clear();
              selectRole=null;
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      )
    );
  }

  Scaffold buildScaffoldData() {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doctors',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildDoctorList(firestoreService.getDoctorsWithLocation()),
            const SizedBox(height: 16.0),
            const Text(
              'Students',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
                _buildUserList(firestoreService.getStudents()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNotBox,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList(Stream<QuerySnapshot> stream) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found for this role.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final user = snapshot.data!.docs[index];
            final userData = user.data() as Map<String, dynamic>;
            final userId = user.id;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text('Name: ${userData['full_name'] ?? 'No Name'}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${userData['id'] ?? 'No ID'}'),
                    Text('Email: ${userData['email'] ?? 'No Email'}'),
                  ],
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete this user?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  firestoreService.deleteUser(userId);
                                  Navigator.pop(context);
                                  showSnackBar(context, 'User deleted successfully');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed:(){
                        _showEditUserDialog(context,userId,userData);
                      },
                      icon: Icon(Icons.update),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorList(Stream<List<Map<String, dynamic>>> doctorsStream) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: doctorsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No doctors found.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final doctorData = snapshot.data![index];
            final Timestamp? timestamp = doctorData['timestamp'] as Timestamp?;
            final DateTime? dateTime = timestamp?.toDate();
            final doctorId = doctorData['uid'];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(doctorData['full_name'] ?? 'No Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${doctorData['id'] ?? 'No ID'}'),
                    Text('Email: ${doctorData['email'] ?? 'No Email'}'),
                    Text('Location: ${doctorData['location'] ?? 'No Location'}'),
                    Text('اخر ظهور  ${dateTime != null ? dateTime.toString() : 'No Timestamp'}'),
                  ],
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete this user?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  firestoreService.deleteUser(doctorId);
                                  Navigator.pop(context);
                                  showSnackBar(context, 'User deleted successfully');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed:(){
                        _showEditUserDialog(context,doctorId,doctorData);
                      },
                      icon: Icon(Icons.update),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> userData) async {
    final TextEditingController editFullNameController =
    TextEditingController(text: userData['full_name']);
    final TextEditingController editIdController =
    TextEditingController(text: userData['id']);


    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Full Name'),
                TextField(controller: editFullNameController),
                const SizedBox(height: 8),
                const Text('ID'),
                TextField(controller: editIdController),
                const SizedBox(height: 16,),
                Row(
                  children: [
                    Checkbox(
                      value: resetPassword,
                      onChanged:(bool? value){
                        if(value != null){
                          resetPassword=value ?? false;
                        }
                        (context as Element).markNeedsBuild();
                      },
                    ),
                    const Text('Reset Password'),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                firestoreService.updateUser(
                  userId,
                  editFullNameController.text,
                  editIdController.text,
                  resetPassword,
                );
                Navigator.of(context).pop();
                showSnackBar(context, 'User updated successfully');
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:project_wifi_scan/screens/login_page.dart';
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
//         .doc(currentUser.uid)
//         .get();
//     return userDoc.exists && userDoc.data()?['role'] == 'assistant';
//   }
//
//
//   void _showAddDialog(BuildContext context, String initialUserType) {
//     final nameController = TextEditingController();
//     final idController = TextEditingController();
//     final emailController = TextEditingController();
//     final passwordController = TextEditingController();
//     // يمكنك إضافة المزيد من البيانات هنا
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
//                     items: ['student','doctor']
//                         .map((value) => DropdownMenuItem(value: value, child: Text(value)))
//                         .toList(),
//                     onChanged: (newValue){
//                       if (newValue !=null){
//                         stepState(() => selectedUserType = newValue);
//                       }
//                     },
//                   ),
//
//                   TextFormField(
//                     controller: nameController,
//                     decoration: const InputDecoration(labelText:'Full Name'),
//                   ),
//                   TextFormField(
//                     controller: idController,
//                     decoration: const InputDecoration(labelText:'ID' ),
//                     keyboardType: TextInputType.number,
//                   ),
//                   TextFormField(
//                     controller: emailController,
//                     decoration: const InputDecoration(labelText: 'Email'),
//                   ),
//                   TextFormField(
//                     controller: passwordController,
//                     obscureText: true,
//                     decoration: const InputDecoration(labelText: 'Password'),
//                   ),
//                 ],
//               ),
//             ),
//
//             actions: [
//               TextButton(
//                 onPressed:() async {
//                   final name = nameController.text.trim();
//                   final id = idController.text.trim();
//                   final email = emailController.text.trim();
//                   final password = passwordController.text.trim();
//                   if (name.isEmpty ||id.isEmpty || email.isEmpty || !email.contains('@') || password.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please enter valid information')),
//                     );
//                     return;
//                   }
//
//                   try {
//                     final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//                       email: email,
//                       password: password,
//                     );
//                     final uid = userCredential.user?.uid;
//                     if (uid == null) {
//                       throw Exception('Failed to get user UID');
//                     }
//                     final data = {
//                       'name': name,
//                       'email': email,
//                       'role': selectedUserType,
//                       'id': id,
//                     };
//
//                     await firestore
//                         .collection(selectedUserType == 'student' ? 'students' : 'doctors')
//                         .doc(uid)
//                         .set(data);
//                     if (!context.mounted) return;
//                     Navigator.pop(context);
//                   } catch (e) {
//                     if (!context.mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Failed to add user: $e')),
//                     );
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
//     final nameController = TextEditingController(text: data['name']);
//     final idController = TextEditingController(text: data['id'] );
//     final emailController = TextEditingController(text: data['email']);
//     // يمكنك إضافة المزيد من البيانات هنا
//
//     showDialog(
//       context: context,
//       builder:(_) => AlertDialog(
//         title: Text('Edit $userType'),
//         content: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: idController,
//                 decoration: const InputDecoration(labelText: 'ID'),//
//               ),
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Full Name'),
//               ),
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//               ),
//             ],
//           ),
//         ),
//
//         actions: [
//           TextButton(
//             onPressed: () async{
//               final updatedData = {
//                 'id': idController.text.trim(),
//                 'name': nameController.text.trim(),
//                 'email': emailController.text.trim(),
//               };
//               if (userType == 'student') {
//                 final newStudentid = idController.text.trim();
//                 final studentSnapshot = await firestore
//                     .collection('students')
//                     .where('id',isEqualTo: newStudentid)
//                     .get();
//                 if (studentSnapshot.docs.isNotEmpty && studentSnapshot.docs.first.id != id) {
//                   if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Student ID already exists')),
//                   );
//                   return;
//                 }
//               }
//
//               await firestore
//                   .collection(userType == 'student'? 'students': 'doctors')
//                   .doc(id)
//                   .update(updatedData);
//               if (!context.mounted) return; //لتحقق من context بأنه صالح (سليم).
//               Navigator.pop(context);
//             },
//             child: const Text('Save'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUserDataTable(String userType){
//     return StreamBuilder<QuerySnapshot>(
//       stream: firestore
//           .collection(userType == 'student'? 'students':'doctors')
//           .orderBy('name')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//         final userDocs = snapshot.data!.docs;
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('List of ${userType == 'student'? 'students':'doctors'}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                 columnSpacing: 16,
//                 columns: const[
//                   DataColumn(label: Text('ID')),
//                   DataColumn(label: Text('Name')),
//                   DataColumn(label: Text('Email')),
//                   DataColumn(label: Text('Actions')),
//                   // يمكنك إضافة المزيد من البيانات هنا
//                 ],
//                 rows: userDocs.map((user) {
//                   final data = user.data() as Map<String, dynamic>;
//                   return DataRow(cells:[
//                     DataCell(Text(data['id'] ?? 'Not Available')),
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
//                                   title: const Text('Delete confirmation'),
//                                   content: const Text('Are you sure you want to delete this user?'),
//                                   actions: [
//                                     TextButton(
//                                       child: const Text('Yes'),
//                                       onPressed: () async {
//                                         await firestore
//                                             .collection(userType == 'student' ? 'students' : 'doctors')
//                                             .doc(user.id)
//                                             .delete();
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
//             onPressed: () => _showAddDialog(context, 'Student'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.person_add),
//             tooltip: 'Add doctor',
//             onPressed: () => _showAddDialog(context, 'Doctor'),
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
//                 _buildUserDataTable('student'),
//                 const SizedBox(height: 24),
//                 _buildUserDataTable('doctor'),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


