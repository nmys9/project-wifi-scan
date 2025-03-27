import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getDoctorsLocations() async {
  List<Map<String, dynamic>> doctorsLocations = [];
  QuerySnapshot querySnapshot =
  await FirebaseFirestore.instance.collection('doctor_locations').get();

  for (var doc in querySnapshot.docs) {
    var doctorData = doc.data() as Map<String, dynamic>;
    doctorsLocations.add({
      'full_name': doctorData['full_name'],
      'location': doctorData['location'],
    });
  }
  return doctorsLocations;
}