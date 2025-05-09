// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../screens/register_user.dart';
// import '../widgets/user_type_item.dart';
//
// import 'login_page.dart';
//
// class UserType extends StatelessWidget{
//   const UserType({super.key});
//
//   static const String id='UserType';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Type'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: ListView(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: GestureDetector(
//                   onTap: (){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context)=> const RegisterUser(role: 'student'),
//                     ),
//                     );
//                     print('student');
//                   },
//                   child: UserTypeItem(
//                     name: 'Student',
//                     imagePath: 'assets/student.png',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30,),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: (){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context)=> const RegisterUser(role: 'doctor'),
//                       ),
//                     );
//                     print('doctor');
//                   },
//                   child: UserTypeItem(
//                     name: 'Doctor',
//                     imagePath: 'assets/doctor.png',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30,),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: (){
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context)=> const RegisterUser(role: 'assistant'),
//                       ),
//                     );
//                     print('assistant');
//                   },
//                   child: UserTypeItem(
//                     name: 'Academic Assistant',
//                     imagePath: 'assets/academic_assistant.png',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'do have an account? ',
//                     style: TextStyle(
//                       fontSize: 20,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: (){
//                       Navigator.pushNamed(context, Login.id);
//                     },
//                     child: const Text(
//                       ' LogIn',
//                       style: TextStyle(
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/register_user.dart';
import '../widgets/user_type_item.dart';

import 'login_page.dart';

class UserType extends StatelessWidget{
  const UserType({super.key});

  static const String id='UserType';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Type'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            shrinkWrap: true, // مهم عشان الـ ListView ياخد أقل مساحة ممكنة
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=> const RegisterUser(role: 'student'),
                    ),
                  );
                  print('student');
                },
                child: UserTypeItem( // شلت الـ Expanded هنا
                  name: 'Student',
                  imagePath: 'assets/student.png',
                ),
              ),
              const SizedBox(height: 30,),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=> const RegisterUser(role: 'doctor'),
                    ),
                  );
                  print('doctor');
                },
                child: UserTypeItem( // شلت الـ Expanded هنا
                  name: 'Doctor',
                  imagePath: 'assets/doctor.png',
                ),
              ),
              const SizedBox(height: 30,),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context)=> const RegisterUser(role: 'assistant'),
                    ),
                  );
                  print('assistant');
                },
                child: UserTypeItem( // شلت الـ Expanded هنا
                  name: 'Academic Assistant',
                  imagePath: 'assets/academic_assistant.png',
                ),
              ),
              const SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'do have an account? ',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, Login.id);
                    },
                    child: const Text(
                      ' LogIn',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}