import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<WiFiAccessPoint> _wifiList=[];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }
  
  Future<void> _requestPermissions() async{
    PermissionStatus status=await Permission.location.request();

    if (status.isGranted) {
      print('Location permission granted');
    } else if (status.isDenied) {
      print('Location permission denied');
    } else if (status.isPermanentlyDenied) {
      print('Location permission permanently denied');
    }
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
            ElevatedButton(
                onPressed: _scanWiFi,
                child: const Text('مسح الشبكات القريبة')
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
