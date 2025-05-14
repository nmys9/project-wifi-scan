import 'package:cloud_firestore/cloud_firestore.dart';

Map<String,double> calculateLocation(List<Map<String,dynamic>> wifiList,List<QueryDocumentSnapshot > data){
  Map<String,double> locationScores={};
  double confidenceThreshold = 0.1;

  for(var wifi in wifiList){
    for(var doc in data ){
      Map<String,dynamic> docData=doc.data() as Map<String,dynamic>;
      if(wifi['bssid'].toString().toUpperCase() == docData['bssid'].toString().toUpperCase()){
        double rssiAvg=(docData['rssi_max']+docData['rssi_min'])/2;
        double rssiDiff=(wifi['rssi']-rssiAvg).abs();

        double weight=1/(rssiDiff+1);

        String locationName=doc['location_name'];
        locationScores[locationName]=(locationScores[locationName] ?? 0)+weight;
      }
    }
  }

  if (locationScores.isEmpty) {
    return {"خارج الجامعة": 0};
  }
  String bestLocation =locationScores.keys.reduce((a,b)=> locationScores[a]! > locationScores[b]! ? a: b);

  double bestScore = locationScores[bestLocation]!;

  print("Location Scores: $locationScores");
  print("Best Location: $bestLocation, Best Score: $bestScore, Threshold: $confidenceThreshold");

  if(bestScore >= confidenceThreshold){
    return {bestLocation: bestScore};
  }else{
    return {"داخل الجامعة": bestScore};
  }


  // return {bestLocation:locationScores[bestLocation]!};
}