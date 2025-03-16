import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class WiFiDataScreen extends StatefulWidget {
  @override
  _WiFiDataScreenState createState() => _WiFiDataScreenState();
}

class _WiFiDataScreenState extends State<WiFiDataScreen> {
  final Dio dio = Dio(); // استخدمنا Dio لإجراء الطلبات
  List<Map<String, dynamic>> _wifiData = [];

  @override
  void initState() {
    super.initState();
    _fetchWiFiData(); // جلب البيانات عند بداية تشغيل الشاشة
  }

  // وظيفة لجلب البيانات من API باستخدام GET
  Future<void> _fetchWiFiData() async {
    try {
      // final response = await dio.get('http://127.0.0.1:8000/get/');
      final response = await dio.get('http://10.0.2.2:8000/get/');

      if (response.statusCode == 200) {
        setState(() {
          _wifiData = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print('Failed to load WiFi data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WiFi Data')),
      body: ListView.builder(
        itemCount: _wifiData.length,
        itemBuilder: (context, index) {
          final wifi = _wifiData[index];
          return ListTile(
            title: Text('SSID: ${wifi['ssid']}'),
            subtitle: Text('BSSID: ${wifi['bssid']}, RSSI Min: ${wifi['rssi_min']}, RSSI Max: ${wifi['rssi_max']}'),
          );
        },
      ),
    );
  }
}

