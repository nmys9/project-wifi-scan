import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../screens/login_page.dart';
import '../widgets/user_text_field.dart';

import '../widgets/register_user.dart';
import '../widgets/show_snack_bar.dart';
import '../widgets/button.dart';


class RegisterUser extends StatefulWidget{
  const RegisterUser({super.key,this.role});

  static const String id='RegisterUser';
  final String? role;
  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  String? id;
  String? fullName,email,password;
  GlobalKey<FormState> formKey=GlobalKey();
  bool isLoding=false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoding,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Center(
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add ${widget.role} Info',
                        style: const TextStyle(
                            fontSize: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60,),
                  UserFormTextField(
                    onChanged: (data){
                      fullName=data;
                    },
                    hintText: 'Full Name',
                  ),
                  const SizedBox(height: 20,),
                  UserFormTextField(
                    onChanged: (data){
                      id=data;
                    },
                    hintText: 'ID',
                  ),
                  const SizedBox(height: 20,),
                  UserFormTextField(
                    onChanged: (data){
                      email=data;
                    },
                    hintText: 'Email',
                  ),
                  const SizedBox(height: 20,),
                  UserFormTextField(
                    onChanged: (data){
                      password=data;
                    },
                    hintText: 'Password',
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 75,
                  ),

                  Button(
                    onTap: ()async{
                      if(formKey.currentState!.validate()){
                        isLoding=true;
                        setState(() {

                        });
                        try{
                          await registerUser(
                              fullName: fullName!,
                              id: id!,
                              email: email!,
                              password: password!,
                              role: widget.role!,
                          );
                          Navigator.pushNamed(context, Login.id);
                        }on FirebaseAuthException catch(e){
                          if (e.code == 'weak-password') {
                            showSnackBar(context,'The password provided is too weak.');
                          } else if (e.code == 'email-already-in-use') {
                            showSnackBar(context, 'The account already exists for that email.');
                          }
                        }
                        isLoding=false;
                        setState(() {

                        });
                      }
                    },
                    text: 'Register',
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'do have an account? ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, Login.id);
                        },
                        child: const Text(
                          ' LogIn',
                          style: TextStyle(
                            color: Colors.black,
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




}