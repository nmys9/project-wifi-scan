import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<Map<String, dynamic>>> getDoctorsLocationsStream() {
  return FirebaseFirestore.instance
      .collection('doctor_locations')
      .snapshots()
      .map((QuerySnapshot snapshot){
        return snapshot.docs.map((doc){
          final doctorData = doc.data() as Map<String,dynamic>;
          return {
            'full_name': doctorData['full_name'],
                'location': doctorData['location'],
                'timestamp':doctorData['timestamp'],
          };
        }).toList();
  });


  // List<Map<String, dynamic>> doctorsLocations = [];
  // QuerySnapshot querySnapshot =
  // await FirebaseFirestore.instance.collection('doctor_locations').get();
  //
  // for (var doc in querySnapshot.docs) {
  //   var doctorData = doc.data() as Map<String, dynamic>;
  //   doctorsLocations.add({
  //     'full_name': doctorData['full_name'],
  //     'location': doctorData['location'],
  //     'timestamp':doctorData['timestamp'],
  //   });
  // }
  // return doctorsLocations;doctorsLocations
}