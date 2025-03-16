Map<String,double> calculateLocation(List<Map<String,dynamic>> wifiFingerprintData,List<Map<String,dynamic>> wifiList){
  Map<String,double> locationScores={};

  for(var wifi in wifiList){
    for(var wifiFingerprint in wifiFingerprintData ){
      if(wifi['bssid']==wifiFingerprint['bssid']){
        double rssiAvg=(wifiFingerprint['rssi_max']+wifiFingerprint['rssi_min'])/2;
        double rssiDiff=(wifi['rssi']-rssiAvg).abs();

        double weight=1/(rssiDiff+1);

        String locationName=wifiFingerprint['location_name'];
        locationScores[locationName]=(locationScores[locationName] ?? 0)+weight;
      }
    }
  }
  if (locationScores.isEmpty) {
    return {"No Data": 0};
  }
  String bestLocation =locationScores.keys.reduce((a,b)=> locationScores[a]! > locationScores[b]! ? a: b);

  return {bestLocation:locationScores[bestLocation]!};
}