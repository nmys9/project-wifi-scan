import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'scan_wifi.dart';
import 'screens/assistant/home_page_assistant.dart';
import 'screens/doctor/home_page_doctor.dart';
import 'screens/login_page.dart';
import 'screens/student/home_page_student.dart';
import 'screens/user_type_page.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            color: Colors.indigo,
          )
      ),
      initialRoute: UserType.id,
      routes: {
        UserType.id:(context)=> const UserType(),
        Login.id :(context)=> const Login(),
        HomePageStudent.id :(context) => HomePageStudent(),
        HomePageDoctor.id :(context) => const HomePageDoctor(),
        HomePageAssistant.id :(context) => HomePageAssistant(),
      },
    );
  }
}

























// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:wifi_scan/wifi_scan.dart';
// import 'package:dio/dio.dart';
//
// Future<void> main() async {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final Dio dio = Dio(); // لعمل طلبات الـAPI
//   List<Map<String, dynamic>> _wifiData = []; // بيانات الـAPI
//   List<WiFiAccessPoint> _wifiList = []; // الشبكات الملتقطة من الجوال
//   Map<String, double> locationScores = {}; // لتخزين نتائج الموقع
//   String? bestLocation; // لتخزين أفضل موقع
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     _fetchWiFiData(); // جلب البيانات من الـAPI
//     _startAutoScan(); // بدء الفحص التلقائي
//   }
//
//   // طلب الأذونات
//   Future<void> _requestPermissions() async {
//     PermissionStatus status = await Permission.location.request();
//     PermissionStatus backgroundStatus = await Permission.locationAlways.request();
//
//     if (status.isGranted && backgroundStatus.isGranted) {
//       print('Location permission granted');
//     } else {
//       print('Location permission denied');
//     }
//   }
//
//   // جلب بيانات الواي فاي من الـAPI
//   Future<void> _fetchWiFiData() async {
//     try {
//       final response = await dio.get('http://10.0.2.2:8000/get/');
//       if (response.statusCode == 200) {
//         setState(() {
//           _wifiData = List<Map<String, dynamic>>.from(response.data);
//         });
//       } else {
//         print('Failed to load WiFi data');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   // مسح الواي فاي كل 5 ثواني
//   void _startAutoScan() {
//     Timer.periodic(const Duration(seconds: 5), (timer) {
//       _scanWiFi();
//     });
//   }
//
//   // فحص الواي فاي
//   Future<void> _scanWiFi() async {
//     final canScan = await WiFiScan.instance.canStartScan();
//     if (canScan == CanStartScan.yes) {
//       await WiFiScan.instance.startScan();
//       await Future.delayed(const Duration(seconds: 2));
//
//       final results = await WiFiScan.instance.getScannedResults();
//       setState(() {
//         _wifiList = results;
//       });
//
//       // بعد فحص الشبكات، نقوم بحساب الموقع باستخدام البيانات المستلمة من الجوال والـAPI
//       locationScores = calculateLocation(_wifiList.map((wifi) {
//         return {
//           'bssid': wifi.bssid,
//           'rssi': wifi.level,
//         };
//       }).toList(), _wifiData);
//
//       print(locationScores); // طباعة الموقع المحسوب
//
//       // تحديد الموقع الذي يحتوي على أعلى درجة
//       String bestLocation = locationScores.entries
//           .reduce((a, b) => a.value > b.value ? a : b)
//           .key;
//
//       print('Best location: $bestLocation');
//     } else {
//       print("لا يمكن بدء المسح.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('WiFi Scanner & Location'),
//         ),
//         body: Column(
//           children: [
//             const Text(
//               "The list of networks is updated automatically every 5 seconds",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             if (bestLocation != null)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Best Location: $bestLocation', // طباعة الموقع الأفضل
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _wifiList.length,
//                 itemBuilder: (context, index) {
//                   final wifi = _wifiList[index];
//                   return ListTile(
//                     title: Text("SSID : ${wifi.ssid}"),
//                     subtitle: Text("RSSI : ${wifi.level} dBm"),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// Map<String, double> calculateLocation(
//     List<Map<String, dynamic>> receivedData, List<Map<String, dynamic>> fingerprintList) {
//   Map<String, double> locationScores = {};
//
//   for (var receivedAp in receivedData) {
//     for (var storedFp in fingerprintList) {
//       if (receivedAp['bssid'] == storedFp['bssid']) {
//         double rssiDiff = (receivedAp['rssi'] - (storedFp['rssi_min'] + storedFp['rssi_max']) / 2).abs();
//         double weight = 1 / (rssiDiff + 1);
//         locationScores[storedFp['location_name']] = locationScores.putIfAbsent(storedFp['location_name'], () => 0) + weight;
//       }
//     }
//   }
//
//   return locationScores;
// }
//
//
//
//
//
//
//
//
//
//
//










// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:wifi_scan/wifi_scan.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
//
//   service.startService();
// }
//
// void onStart(ServiceInstance service) async {
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//
//   }
//
//   Timer.periodic(const Duration(seconds: 10), (timer) async {
//     final canScan = await WiFiScan.instance.canStartScan();
//     if (canScan == CanStartScan.yes) {
//       await WiFiScan.instance.startScan();
//       final results = await WiFiScan.instance.getScannedResults();
//       print("WiFi Networks Found: ${results.map((e) => e.ssid).toList()}");
//     }
//   });
// }
//
// bool onIosBackground(ServiceInstance service) {
//   return true;
// }
//
//
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeService();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   List<WiFiAccessPoint> _wifiList=[];
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     _startAutoScan();
//   }
//
//   Future<void> _requestPermissions() async{
//     PermissionStatus status=await Permission.location.request();
//     PermissionStatus backgroundStatus = await Permission.locationAlways.request();
//
//     if (status.isGranted && backgroundStatus.isGranted) {
//       print('Location permission granted');
//     } else if (status.isDenied || backgroundStatus.isDenied) {
//       print('Location permission denied');
//     } else if (status.isPermanentlyDenied || backgroundStatus.isPermanentlyDenied) {
//       print('Location permission permanently denied');
//     }
//   }
//
//   void _startAutoScan(){
//     _timer=Timer.periodic(const Duration(seconds: 5), (timer){
//       _scanWiFi();
//     });
//   }
//
//   Future<void> _scanWiFi() async{
//     final canScan=await WiFiScan.instance.canStartScan();
//     if(canScan==CanStartScan.yes){
//       await WiFiScan.instance.startScan();
//       await Future.delayed(const Duration(seconds: 2));
//
//       final results=await WiFiScan.instance.getScannedResults();
//       setState(() {
//         _wifiList=results;
//       });
//     }else{
//       print("لا يمكن بدء المسح. تحقق من الأذونات أو الإعدادات.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('WiFi Scanner'),
//         ),
//         body: Column(
//           children: [
//             const Text(
//               "The list of networks is updated automatically every 5 seconds",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _wifiList.length,
//                 itemBuilder: (context,index){
//                   final wifi=_wifiList[index];
//                   return ListTile(
//                     title: Text("SSID : ${wifi.ssid}"),
//                     subtitle: Text("RSSI : ${wifi.level} dBm"),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//
//     );
//   }
// }
//
//















// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
//
//
// Future<void> main() async {
//   runApp(MyApp());
// }
//
//
// // void onStart() {
// //   // تنفيذ العمليات التي تريد القيام بها عند بدء الخدمة
// //   print('Service started');
// // }
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'WiFi Data',
//       home: WiFiDataScreen(),
//     );
//   }
// }
//
// class WiFiDataScreen extends StatefulWidget {
//   @override
//   _WiFiDataScreenState createState() => _WiFiDataScreenState();
// }
//
// class _WiFiDataScreenState extends State<WiFiDataScreen> {
//   final Dio dio = Dio(); // استخدمنا Dio لإجراء الطلبات
//   List<Map<String, dynamic>> _wifiData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchWiFiData(); // جلب البيانات عند بداية تشغيل الشاشة
//   }
//
//   // وظيفة لجلب البيانات من API باستخدام GET
//   Future<void> _fetchWiFiData() async {
//     try {
//       // final response = await dio.get('http://127.0.0.1:8000/get/');
//       final response = await dio.get('http://10.0.2.2:8000/get/');
//
//       if (response.statusCode == 200) {
//         setState(() {
//           _wifiData = List<Map<String, dynamic>>.from(response.data);
//         });
//       } else {
//         print('Failed to load WiFi data');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('WiFi Data')),
//       body: ListView.builder(
//         itemCount: _wifiData.length,
//         itemBuilder: (context, index) {
//           final wifi = _wifiData[index];
//           return ListTile(
//             title: Text('SSID: ${wifi['ssid']}'),
//             subtitle: Text('BSSID: ${wifi['bssid']}, RSSI Min: ${wifi['rssi_min']}, RSSI Max: ${wifi['rssi_max']}'),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//

//
//
//
//
//
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:wifi_scan/wifi_scan.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
//
// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//   );
//
//   service.startService();
// }
//
// void onStart(ServiceInstance service) async {
//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }
//
//   Timer.periodic(const Duration(seconds: 10), (timer) async {
//     final canScan = await WiFiScan.instance.canStartScan();
//     if (canScan == CanStartScan.yes) {
//       await WiFiScan.instance.startScan();
//       final results = await WiFiScan.instance.getScannedResults();
//       print("WiFi Networks Found: ${results.map((e) => e.ssid).toList()}");
//     }
//   });
// }
//
// bool onIosBackground(ServiceInstance service) {
//   return true;
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeService();
//   runApp(const MyApp());
// }
//
// class WiFiService {
//   final Dio dio;
//   WiFiService(this.dio);
//
//   Future<String?> sendWiFiDataToServer(
//       List<Map<String, dynamic>> wifiData) async {
//     try {
//       // var response= await dio.get(
//       //   'http://127.0.0.1:8000/get/',
//       //   options: Options(headers: {'Content-Type': 'application/json'}),
//       // );
//       var response = await dio.post(
//         //'http://127.0.0.1:8000/post',
//         'http://127.0.0.1:8000/post/',
//         options: Options(headers: {'Content-Type': 'application/json'}),
//         data: wifiData,
//       );
//
//       if (response.statusCode == 200) {
//         return response.data['estimated_location'];
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   List<WiFiAccessPoint> _wifiList = [];
//   Timer? _timer;
//   String? _location = '';
//   final WiFiService wifiService = WiFiService(Dio());
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     _startAutoScan();
//     enableGPS();
//   }
//
//   Future<void> enableGPS() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//     }
//   }
//
//   Future<void> _requestPermissions() async {
//     PermissionStatus status = await Permission.location.request();
//     PermissionStatus backgroundStatus =
//         await Permission.locationAlways.request();
//     await Permission.locationWhenInUse.request();
//     await Permission.locationAlways.request();
//
//
//     if (status.isGranted && backgroundStatus.isGranted) {
//       print('Location permission granted');
//     } else if (status.isDenied || backgroundStatus.isDenied) {
//       print('Location permission denied');
//     } else if (status.isPermanentlyDenied ||
//         backgroundStatus.isPermanentlyDenied) {
//       print('Location permission permanently denied');
//     }
//   }
//
//   void _startAutoScan() {
//     _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       _scanWiFi();
//     });
//   }
//
//   // Future<String?> sendWifiDataToServer(List<Map<String,dynamic>> wifiData)async{
//   //   final url=Uri.parse('http://192.168.0.104:8000/post');
//   //   final response=await http.post(
//   //     url,
//   //     headers: {"Content-Type":"application/json"},
//   //     body: jsonEncode(wifiData),
//   //   );
//
//   //   if(response.statusCode == 200){
//   //     return jsonDecode(response.body)['estimated_location'];
//   //   }else{
//   //     print("خطأ في تحديد الموقع: ${response.body}");
//   //     return null;
//   //   }
//
//   // }
//
//   Future<void> _scanWiFi() async {
//     final canScan = await WiFiScan.instance.canStartScan();
//     if (canScan == CanStartScan.yes) {
//       await WiFiScan.instance.startScan();
//       await Future.delayed(const Duration(seconds: 2));
//
//       final results = await WiFiScan.instance.getScannedResults();
//
//       List<Map<String, dynamic>> wifiData = results.map((wifi) {
//         return {
//           'ssid': wifi.ssid,
//           'bssid': wifi.bssid,
//           'rssi': wifi.level,
//         };
//       }).toList();
//
//       String? location = await wifiService.sendWiFiDataToServer(wifiData);
//
//       setState(() {
//         _location = location ?? "لم يتم تحديد الموقع";
//       });
//     } else {
//       print("لا يمكن بدء المسح. تحقق من الأذونات أو الإعدادات.");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('WiFi Scanner'),
//         ),
//         body: Container(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               _location!,
//               style: const TextStyle(
//                 fontSize: 32,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
