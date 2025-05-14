
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future sendNotification({
  required String fcmToken,
  required String title,
  required String body,
  required String userID,
  required BuildContext context,
}) async {

  await FirebaseFirestore.instance.collection('notifications').add({
    'title': title,
    'body': body,
    'user_id': userID,
    'timestamp': FieldValue.serverTimestamp(),
  });
    if(fcmToken == ""){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User has no FCM token")),
      );
      return ;
    }
    final accessToken = await getOAuthToken();
    var headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    var request = http.Request('POST', Uri.parse('https://fcm.googleapis.com/v1/projects/fir-tutorial-c4e55/messages:send'));
    request.body = json.encode({
      "message": {
        "token": fcmToken,
        "notification": {
          "title": title,
          "body": body,
        },
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    log("response___ ${await response.stream.bytesToString()}");
    if (response.statusCode == 200) {
      print("done ${response.statusCode}");
    } else {
      print("error");
    }
}


Future getOAuthToken() async {
  final int iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final int exp = iat + 3600;
  final jwt = JWT(
    {
      'iss': 'firebase-adminsdk-fbsvc@fir-tutorial-c4e55.iam.gserviceaccount.com',
      'sub': 'firebase-adminsdk-fbsvc@fir-tutorial-c4e55.iam.gserviceaccount.com',
      'aud': 'https://oauth2.googleapis.com/token',
      'iat': iat,
      'exp': exp,
      'scope': 'https://www.googleapis.com/auth/firebase.messaging',
    },
  );
  var privateKey = "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC/bJUDTAM73tDu\n8PGZEqFR/Ok0jPLFvMMCRxzyu7UhKp1KAKxDxfRTc/kBf1timw2y+P2/fxNPEhZ1\nTbiQuv/vshoY1WblGNr9OnbmLxcQUehuwTS75XryFbHMF9HHexyXLi9W4YwjpA67\n1hyXpmpaI2AB3ig9t3n+q8pk+H6kWB92yr+LaawT0VWSrTU/aue59GJIAu8Luoog\nn50TdxMh0ToRGSNivs1Te5zoQ6iVm3P9IT93+0vA8t1UIJLqVLA8GokCCJnPbfl+\n1JHfnD0PtZgeGLTKd8Rx6HlC5Fxh6rPJCpf5tTVTkc1ONUbm4VENOBbR2l+fiSD4\nLDfRUwHhAgMBAAECggEAF8BdnkLF5Ugt/R0mTQueZUblRLZMaok+WmpVHC/QN0+g\no+MA0jPzWeYk5QZWt3MXuGI5UekZjeZnpPcXdIB6FdVadEReTQTQKeV22p7If3zk\n7dZz4vCEAxpQAkveT/W67sM179NyiPrn3Rn3AutiJ3xbgup8FxRMmHMxB2WR3nWI\nNNPiWZm5SE7LiRsIx90g1cx6xlrSrQYz5CPJfWCsBpfEVaxcU/qZD2lUXue2+BEJ\nzWuVb+P3R0odeyc6FPqq+sVorMB7mjf9Rpox1FS4YWg+TjDpNoRyRyMYS0xAybIh\nLYBJfR0WXlLpiJU3u8GOYPRCnV6SiHTW+Vud41ysdQKBgQDynPqf1CTiUZcDvaRE\n6f+eVzFyaJc9q36j4xFCaiR8l8v+vF17BGM5kkzfQScFGXq54wu77GzxELpd04FA\n4H3qgb3gGRuncm9SzQIVIOVd5mOaU6X0DZ+XvPPTy/xjW8BA1K0Mj7LZ7CsehXo/\nsF8vFKd6xmAfLls1MhZVNPqXywKBgQDJ/IjdRh7d3Tc/9s640DjiGJnt99I/013x\nxeSlqBGYxsl14kZLE79/1jifXB6QHrMvSK+fPqd4sWpEgelr3jk0+0abxDEYA7Q7\nw3quaCSVqGHmFPAh5fBhUM+EAgSLitKOQB37p8Ir3SUZm4JsoJfUd7CDpcZWAZs+\ncwyZzelfgwKBgGRez0zaLlw3FvvkNBaSnD78oadMX+2SinTw1s4cLXYiMrHzadUf\n7pD91rGyOZthfCV1KgCYAkYE/qUcgGe/uDgRbuVMXeV7cVTXHZpyHpInY2OQYaLD\nFBhpgpJH3OWaKsJneiQtOvfvPbOF0xqQNAC9UcB4W4Hq4q7yRsz/ewDbAoGAT76G\nAmY2tX0q3PQB9XEvpAP2cb8PoOdABb4NYWGTYO/KheIJwoZPapcWz8O8xUV5lMdr\nnsFLuRjCTb3EfDPF/ibeX4z7nPGJbLbmbojrOLK7w+ysSZXQa3tOEl4BkV4DdunV\nbI9014B9rzh4K47ToqyGYdNHFJmZwvQFG4vyASUCgYBFpRefuu0Wt25m1SqmXQ2P\nFsGMv0tR9wDYQXacy4f37cMeiNjQDBksGAmBBocC9075QoWsW8Tt5NU+EIUyf9vQ\nO+H4F4Ifg981QE23sxI1VMYIQ5Ln7QnntQq779B5LQ32sC+q2lNc5Bwmcvuzl5Uv\ncV4gHBTzBNzZihOVUZvrVA==\n-----END PRIVATE KEY-----\n";


  final token = jwt.sign(RSAPrivateKey(privateKey),algorithm: JWTAlgorithm.RS256);

  final response = await http.post(
    Uri.parse('https://oauth2.googleapis.com/token'),
    body: {
      'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      'assertion': token,
    },
  );
  if (response.statusCode == 200) {
    final oauth2Token = json.decode(response.body)['access_token'];
    return oauth2Token ;
    // print('OAuth2 Token: $oauth2Token');
  } else {
    print('Failed to get OAuth2 token. Status code: ${response.statusCode}');
    print('Response: ${response.body}');
  }
}
