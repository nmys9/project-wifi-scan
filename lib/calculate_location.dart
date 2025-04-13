import 'package:cloud_firestore/cloud_firestore.dart';

Map<String,double> calculateLocation(List<Map<String,dynamic>> wifiList,List<QueryDocumentSnapshot > data){
  Map<String,double> locationScores={};
  double confidenceThreshold = 0.7;

  for(var wifi in wifiList){
    for(var doc in data ){
      Map<String,dynamic> docData=doc.data() as Map<String,dynamic>;
      if(wifi['bssid']==docData['bssid']){
        double rssiAvg=(docData['rssi_max']+docData['rssi_min'])/2;
        double rssiDiff=(wifi['rssi']-rssiAvg).abs();

        double weight=1/(rssiDiff+1);

        String locationName=doc['location_name'];
        locationScores[locationName]=(locationScores[locationName] ?? 0)+weight;
      }
    }
  }
  if (locationScores.isEmpty) {
    return {"غير موجود بالجامعة": 0};
  }
  String bestLocation =locationScores.keys.reduce((a,b)=> locationScores[a]! > locationScores[b]! ? a: b);

  if (locationScores[bestLocation]! < confidenceThreshold) {
    return {" غير موجود بالجامعة": 0};
  }

  return {bestLocation:locationScores[bestLocation]!};
}