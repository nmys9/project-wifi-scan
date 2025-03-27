import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../screens/assistant/home_page_assistant.dart';
import '../widgets/user_text_field.dart';
import 'doctor/home_page_doctor.dart';
import 'student/home_page_student.dart';
import 'user_type_page.dart';

import '../function/show_snack_bar.dart';
import '../widgets/button.dart';



class Login extends StatefulWidget{
  const Login({super.key});

  static const String id='Login';


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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'My App',
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
                  const Row(
                    children: [
                      Text(
                        'LogIn',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
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
                          await signInUser();
                          await navigateBasedOnRole(context);
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'don\'t have an account? ',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, UserType.id);
                        },
                        child: const Text(
                          ' Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInUser() async {
    UserCredential userCredential=await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email!,
      password: password!,
    );
  }

  Future<void> navigateBasedOnRole(BuildContext context) async{
    User? user=FirebaseAuth.instance.currentUser;
    if(user != null){
      String uid=user.uid;
      DocumentSnapshot userDoc=await FirebaseFirestore.instance.
                                      collection('users').doc(uid).get();
      if(userDoc.exists){
        var userData= userDoc.data() as Map<String, dynamic>; // تحقق من نوع البيانات
          String role = userData['role'];
          if (role == 'student') {
            Navigator.pushReplacementNamed(context, HomePageStudent.id);
          }else if (role == 'doctor') {
            Navigator.pushReplacementNamed(context, HomePageDoctor.id);
          } else if (role == 'academic_assistant') {
            Navigator.pushReplacementNamed(context, HomePageAssistant.id);
          } else {
            Navigator.pushReplacementNamed(context, HomePageStudent.id); // صفحة افتراضية إذا لم يتم العثور على الدور
          }
      }
    }
  }

}























