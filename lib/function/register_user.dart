import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> registerUser({
  required String fullName,
  required String id,
  required String email,
  required String password,
  required String role,
}) async{
  try{
    UserCredential userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = userCredential.user!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'full_name': fullName,
      'id': id,
      'email': email,
      'password': password,
      'role': role,
    });
  }on FirebaseAuthException catch (e) {
    print('Failed with error code: ${e.code}');
    print('Failed with error message: ${e.message}');
  }

  print('${fullName} - ${id} - ${email} - ${password} - ${role}');
}