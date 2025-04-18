import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_wifi_scan/calculate_location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      print("WiFi Networks Found: ${results.map((e) => e.ssid).toList()}");
    }
  });
}

bool onIosBackground(ServiceInstance service) {
  return true;
}


class ScanWiFi extends StatefulWidget{
  const ScanWiFi({super.key});

  @override
  State<ScanWiFi> createState() => _ScanWiFiState();
}

class _ScanWiFiState extends State<ScanWiFi> {
  List<WiFiAccessPoint> _wifiList = [];
  Timer? _timer;
  List<Map<String,dynamic>> wifiList=[];


  Map<String,dynamic> bestLocation={};

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
    super.initState();
    getData();
    _requestPermissions();
    _startAutoScan();
    enableGPS();
  }

  Future<void> enableGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.location.request();
    PermissionStatus backgroundStatus = await Permission.locationAlways.request();
    await Permission.locationWhenInUse.request();


    if (status.isGranted && backgroundStatus.isGranted) {
      print('Location permission granted');
    } else if (status.isDenied || backgroundStatus.isDenied) {
      print('Location permission denied');
    } else if (status.isPermanentlyDenied ||
        backgroundStatus.isPermanentlyDenied) {
      print('Location permission permanently denied');
    }
  }



  void _startAutoScan() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _scanWiFi();
    });
  }


  Future<void> _scanWiFi() async{
    final canScan=await WiFiScan.instance.canStartScan();
    if(canScan==CanStartScan.yes){
      await WiFiScan.instance.startScan();
      await Future.delayed(const Duration(seconds: 2));

      final results=await WiFiScan.instance.getScannedResults();


      _wifiList=results;
      wifiList=_wifiList.map((wifi)=>{
        "ssid":wifi.ssid,
        "bssid":wifi.bssid.toUpperCase(),
        "rssi":wifi.level,
      }).toList();

      bestLocation=calculateLocation(wifiList, data);


      if(bestLocation.isNotEmpty){
        String doctorId=FirebaseAuth.instance.currentUser!.uid;
        DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)
            .get();

        if(doctorDoc.exists){
          var doctorData=doctorDoc.data() as Map<String,dynamic>;
          if(doctorData['role'] == 'doctor'){
            String doctorName =doctorData['full_name'];

            DocumentSnapshot existingDoc = await FirebaseFirestore.instance
                .collection('doctor_locations')
                .doc(doctorId)
                .get();

            String? currentLocation =
            existingDoc.exists ? (existingDoc.data() as Map<String, dynamic>)['location'] : null;

            if (currentLocation != bestLocation.keys.first) {
              await FirebaseFirestore.instance
                  .collection('doctor_locations')
                  .doc(doctorId)
                  .set({
                'full_name': doctorName,
                'location': bestLocation.keys.first,
                'timestamp': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          }
        }
      }
    }else{
      print("لا يمكن بدء المسح. تحقق من الأذونات أو الإعدادات.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

