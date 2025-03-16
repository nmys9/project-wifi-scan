import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class WiFiFingerprintApi extends StatefulWidget{
  @override
  State<WiFiFingerprintApi> createState() => _WiFiFingerprintApiState();
}

class _WiFiFingerprintApiState extends State<WiFiFingerprintApi> {
  List<QueryDocumentSnapshot> data=[];

  getData() async{
    QuerySnapshot querySnapshot=
    await FirebaseFirestore.instance.collection('wifiFingerprint').get();
    data.addAll(querySnapshot.docs);
    setState(() {

    });
  }
  @override
  void initState() {
    getData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
   return Scaffold();
  }
}