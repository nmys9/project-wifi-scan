import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

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

  Future<void> _scanWiFi() async{
    final canScan=await WiFiScan.instance.canStartScan();
    if(canScan==CanStartScan.yes){
      await WiFiScan.instance.startScan();
      await Future.delayed(const Duration(seconds: 2));

      final results=await WiFiScan.instance.getScannedResults();
      setState(() {
        _wifiList=results;
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
        body: Column(
          children: [
            const Text(
              "The list of networks is updated automatically every 5 seconds",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: ListView.builder(
                  itemCount: _wifiList.length,
                  itemBuilder: (context,index){
                    final wifi=_wifiList[index];
                    return ListTile(
                      title: Text("SSID : ${wifi.ssid}"),
                      subtitle: Text("RSSI : ${wifi.level} dBm"),
                    );
                  },
                ),
            ),
          ],
        ),
      ),

    );
  }
}
