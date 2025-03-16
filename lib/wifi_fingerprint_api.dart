import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class WiFiFingerprintApi{
  final Dio dio;
  WiFiFingerprintApi(this.dio);

  Future<List<Map<String,dynamic>>> getWifiFingerprintData() async {
    try{
      var response = await dio.get('http://192.168.0.106:8000/get/');
      print(response.data);
      List<Map<String, dynamic>> wifiFingerprintData=
        List<Map<String, dynamic>>.from(jsonDecode(response.data));

      return wifiFingerprintData;
    }catch(e){
      return [];
    }
  }
}