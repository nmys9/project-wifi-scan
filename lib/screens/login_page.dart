import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:project_wifi_scan/screens/access_denied_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/assistant/home_page_assistant.dart';
import '../widgets/user_text_field.dart';
import 'doctor/home_page_doctor.dart';
import 'student/home_page_student.dart';
import 'user_type_page.dart';

import '../widgets/show_snack_bar.dart';
import '../widgets/button.dart';



class Login extends StatefulWidget{
  const Login({super.key,this.role});

  static const String id='Login';
  final String? role;


  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  String? email;
  String? password;
  GlobalKey<FormState> formKey=GlobalKey();
  bool isLoding=false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoding,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        // backgroundColor:kPrimaryColor,
        body:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 75,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.role} login',
                        style: TextStyle(
                            fontSize: 32,
                            color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 75,
                  ),
                  UserFormTextField(
                    onChanged: (data){
                      email=data;
                    },
                    hintText: 'Email',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  UserFormTextField(
                    onChanged: (data){
                      password=data;
                    },
                    hintText: 'Password',
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Button(
                    onTap: ()async{
                      if (formKey.currentState!.validate()) {
                        isLoding=true;
                        setState(() {

                        });
                        try{

                          bool signInSuccess = await signInUser();
                          if(signInSuccess ){
                            // User? user =FirebaseAuth.instance.currentUser;
                            // if( user != null ){
                            //   await _updateFirestoreOnLogin(user.uid, password!, false);
                            // }
                            await navigateBasedOnRole(context);
                          }
                        }on FirebaseAuthException catch(e){
                          if(e.code == 'user-not-found'){
                            showSnackBar(context, 'No user found for that email.');
                          }else if(e.code == 'wrong-password'){
                            showSnackBar(context, 'Wrong password provided for that user.');
                          }
                        }
                        isLoding=false;
                        setState(() {

                        });
                      }else{

                      }
                    },
                    text: 'LogIn',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> signInUser() async {
  //   UserCredential userCredential=await FirebaseAuth.instance.signInWithEmailAndPassword(
  //     email: email!,
  //     password: password!,
  //   );
  // }

  Future<bool> signInUser() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // بعد تسجيل الدخول بنجاح، استعلم عن بيانات المستخدم من Firestore
        final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final String storedRole = userData['role'];
          // final String storedPassword=userData['password'];
          // final String userId=userData['id'].toString();
          final bool? isInitialPassword = userData['is_initial_password'];

          if (storedRole == widget.role) {
            if(isInitialPassword == true){
              final shouldNavigate = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('تنبيه هام'),
                    content: Text('كلمة المرور الحالية هي كلمة مرور ابتدائية. يرجى تغييرها الآن لحماية حسابك.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('لاحقًا'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      TextButton(
                        child: Text('تغيير الآن'),
                        onPressed: () async {
                          showSnackBar(context, 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.');
                          Navigator.of(context).pop(false); // إغلاق مربع الحوار
                          await _sendPasswordResetEmail(user.email!, context);
                          // لا نعتبر تسجيل الدخول ناجحًا هنا حتى يتم تغيير كلمة المرور فعليًا
                          // يمكنك عرض رسالة للمستخدم بأنه تم إرسال رابط إعادة التعيين

                          // قد تحتاج إلى إبقاء المستخدم على شاشة تسجيل الدخول أو توجيهه إلى شاشة انتظار

                        },
                      ),
                    ],
                  );
                },
              );

              await _updateFirestoreOnLogin(user.uid, false);

              return shouldNavigate ?? false;
            }
            else {
              // كلمة المرور ليست ابتدائية، نقوم بتحديثها في Firestore
              // final encryptedPassword = _encryptPassword(password!); // مثال لتشفير كلمة المرور
              print('تسجيل الدخول ناجح بدور: ${widget.role}');
              return true;
            }
          } else {
            // الأدوار غير متطابقة
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('تنبيه'),
                  content: Text('يبدو أن دورك المسجل هو "${widget.role}". يرجى اختيار نوع "$storedRole" لتسجيل الدخول.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('موافق'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            return false;
          }
        } else {
          // المستخدم موجود في Firebase Auth ولكن بياناته غير موجودة في جدول users
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('خطأ'),
                content: Text('لا يوجد بيانات حساب مرتبطة بهذا المستخدم في التطبيق.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('موافق'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          return false;
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      // خطأ في تسجيل الدخول (كلمة السر أو البريد الإلكتروني غير صحيح)
      String errorMessage = 'حدث خطأ أثناء تسجيل الدخول.';
      if (e.code == 'user-not-found') {
        errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة.';
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('خطأ في تسجيل الدخول'),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                child: Text('موافق'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    } catch (e) {
      // خطأ عام
      print('خطأ غير متوقع أثناء تسجيل الدخول: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('خطأ'),
            content: Text('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'),
            actions: <Widget>[
              TextButton(
                child: Text('موافق'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return false;
    }
  }

  Future<void> _sendPasswordResetEmail(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // يمكنك هنا عرض رسالة نجاح للمستخدم
      showSnackBar(context, 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. يرجى التحقق من بريدك الوارد (أو مجلد الرسائل غير المرغوب فيها).');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء إرسال رابط إعادة تعيين كلمة المرور.';
      if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير صالح.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      }
      showSnackBar(context, errorMessage);
    } catch (e) {
      showSnackBar(context, 'حدث خطأ غير متوقع أثناء محاولة إرسال رابط إعادة تعيين كلمة المرور.');
    }
  }

  Future<void> _updateFirestoreOnLogin(String uid, bool isInitialPassword) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'is_initial_password': isInitialPassword,
      });
    } catch (e) {
      print('خطأ في تحديث Firestore عند تسجيل الدخول: $e');
      // يمكنك هنا إضافة معالجة للخطأ إذا لزم الأمر (مثل عرض رسالة للمستخدم)
    }
  }

  Future<void> navigateBasedOnRole(BuildContext context) async{
    User? user=FirebaseAuth.instance.currentUser;
    if(user != null){
      String uid = user.uid;
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<String, dynamic> updateData = {
          'fcm_token': "${prefs.getString('fcmToken')}",
        };
        log("${prefs.getString('fcmToken')}");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updateData);

        var userData = userDoc.data() as Map<String, dynamic>; // تحقق من نوع البيانات

        // Future.delayed(const Duration(seconds: 1), () async {
        //   sendNotification(title: "Test Title", body: "Test Body", fcmToken: userData["fcm_token"]??"" , userID: userDoc.id);
        // });


        String role = userData['role'];
        if (role == 'student') {
          Navigator.pushReplacementNamed(context, HomePageStudent.id);
        }else if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, HomePageDoctor.id);
        } else if (role == 'assistant') {
          Navigator.pushReplacementNamed(context, HomePageAssistant.id);
        } else {
          Navigator.pushReplacementNamed(context, HomePageStudent.id); // صفحة افتراضية إذا لم يتم العثور على الدور
        }
      }
    }
  }
}























