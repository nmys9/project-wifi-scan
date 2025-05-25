import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_wifi_scan/scan_wifi.dart';
import 'package:project_wifi_scan/screens/doctor/doctor_info.dart';
import 'package:project_wifi_scan/screens/doctor/send_notification_page.dart';
import 'package:project_wifi_scan/screens/user_type_page.dart';

class HomePageDoctor extends StatefulWidget {
  const HomePageDoctor({super.key});

  static const String id = 'HomePageDoctor';

  @override
  State<HomePageDoctor> createState() => _HomePageDoctorState();
}

class _HomePageDoctorState extends State<HomePageDoctor> {
  late Future<bool> isDoctorFuture;
  Map<String, dynamic>? doctorData;

  int _selectedIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    isDoctorFuture = checkIfUserIsDoctor();
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
          title: Text(_selectedIndex == 0 ? 'Home Page Doctor' : "Doctor Notifications",style: const TextStyle(color: Colors.white,),),
        actions: [
          IconButton(
            onPressed: ()=> logout(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
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
        items: const[
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

  Widget buildScaffoldData() {
    return FutureBuilder<bool>(
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
