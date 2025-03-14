import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;

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




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<WiFiAccessPoint> _wifiList=[];
  Timer? _timer;
  String? _location='';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startAutoScan();
  }
  
  Future<void> _requestPermissions() async{
    PermissionStatus status=await Permission.location.request();
    PermissionStatus backgroundStatus = await Permission.locationAlways.request();

    if (status.isGranted && backgroundStatus.isGranted) {
      print('Location permission granted');
    } else if (status.isDenied || backgroundStatus.isDenied) {
      print('Location permission denied');
    } else if (status.isPermanentlyDenied || backgroundStatus.isPermanentlyDenied) {
      print('Location permission permanently denied');
    }
  }

  void _startAutoScan(){
    _timer=Timer.periodic(const Duration(seconds: 5), (timer){
      _scanWiFi();
    });
  }

  Future<void> sendWifiDataToServer(List<Map<String,dynamic>> wifiData)async{
    final url=Uri.parse('uri');
    final response=await http.post(
      url,
      headers: {"Content-Type":"application/json"},
      body: jsonEncode(wifiData),
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body)['estimated_location'];
    }else{
      print("خطأ في تحديد الموقع: ${response.body}");
      return null;
    }

  }

  Future<void> _scanWiFi() async{
    final canScan=await WiFiScan.instance.canStartScan();
    if(canScan==CanStartScan.yes){
      await WiFiScan.instance.startScan();
      await Future.delayed(const Duration(seconds: 2));

      final results=await WiFiScan.instance.getScannedResults();

      List<Map<String,dynamic>> wifiData=results.map((wifi){
        return{
          'ssid':wifi.ssid,
          'bssid':wifi.bssid,
          'rssi':wifi.level,
        };
      }).toList();


      String? location = await sendWifiDataToServer(wifiData);


      setState(() {
        _location=location ??  "لم يتم تحديد الموقع";
      });
    }else{
      print("لا يمكن بدء المسح. تحقق من الأذونات أو الإعدادات.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WiFi Scanner'),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _location!,
              style: const TextStyle(
                fontSize: 32,
              ),

            ),
          ),

        ),
      ),

    );
  }
}
