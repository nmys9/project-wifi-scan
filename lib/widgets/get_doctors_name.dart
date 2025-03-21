import 'package:cloud_firestore/cloud_firestore.dart';



Future<List<String>> getDoctorsNames() async {
  List<String> doctorNames = [];
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'doctor')
      .get();

  for (var doc in querySnapshot.docs) {
    var userData = doc.data() as Map<String, dynamic>;
    doctorNames.add(userData['full_name']);
  }
  return doctorNames;
}