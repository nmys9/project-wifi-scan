import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirestoreService{

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference doctorLocations =
  FirebaseFirestore.instance.collection('doctor_locations');

  Future<void> addUser({
    required String full_name,
    required String id,
    required String email,
    required String password,
    required String role,

  })async{
    try{
      UserCredential userCredential= await  FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid=userCredential.user!.uid;

      await  users.doc(uid).set({
        'full_name': full_name,
        'email':email,
        'id':id,
        'is_initial_password':true,
        'role':role
      });
    }on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print('Failed with error message: ${e.message}');
    }

  }
  Stream<QuerySnapshot> getStudents() {
    return users.where('role', isEqualTo: 'student').snapshots();
  }

  Stream<List<Map<String, dynamic>>> getDoctorsWithLocation() {
    return users.where('role', isEqualTo: 'doctor').snapshots().asyncMap((doctorsSnapshot) async {
      List<Map<String, dynamic>> doctorsWithLocation = [];
      for (final doctorDoc in doctorsSnapshot.docs) {
        final doctorData = doctorDoc.data() as Map<String, dynamic>;
        final doctorId = doctorDoc.id;

        // جلب موقع الدكتور بناءً على doctorId (بافتراض تطابقه مع documentId في doctor_locations)
        final locationSnapshot = await doctorLocations.doc(doctorId).get();
        Map<String, dynamic>? locationData;
        if (locationSnapshot.exists) {
          locationData = locationSnapshot.data() as Map<String, dynamic>?;
        }

        doctorsWithLocation.add({
          ...doctorData,
          'location': locationData?['location'],
          'timestamp': locationData?['timestamp'],
        });
      }
      return doctorsWithLocation;
    });
  }

  Future<void> updateUser(String userId, String? newFullName, String? newId,bool resetPassword) async {
    try {
      Map<String, dynamic> updateData = {};
      if (newFullName != null && newFullName.isNotEmpty) {
        updateData['full_name'] = newFullName;
      }
      if (newId != null && newId.isNotEmpty) {
        updateData['id'] = newId;
      }

      if (updateData.isNotEmpty) {
        await users.doc(userId).update(updateData);
      }

      if (resetPassword) {
        await users.doc(userId).update({'is_initial_password': true});
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await users.doc(userId).delete();
      await doctorLocations.doc(userId).delete();

    } catch (e) {
      print('Error deleting user data from Firestore: $e');
    }
  }

}