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
        title: Text(_selectedIndex == 0 ? 'Assistant Home' : "Assistant Notifications",style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            onPressed: ()=> logout(context),
            icon: const Icon(Icons.logout,color: Colors.white,),
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
                textPasswordController.clear();
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
                                  print('Pressed delete for: $doctorId');
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
                setState(() {
                  resetPassword = false;
                });
                Navigator.of(context).pop();

                showSnackBar(context, 'User updated successfully');
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  resetPassword = false;
                });
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



