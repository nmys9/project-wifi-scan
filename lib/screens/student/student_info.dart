import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  Map<String, dynamic>? studentData;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (studentDoc.exists) {
        setState(() {
          studentData = studentDoc.data() as Map<String, dynamic>?;
        });
      } else {
        setState(() {
          studentData = null;
        });
      }
    } else {
      setState(() {
        studentData = null;
      });
    }
  }

  Widget _buildInfoCard(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: studentData == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          children: [
            _buildInfoCard(
              context,
              'Full Name',
              studentData?['full_name'] ?? 'N/A',
              Icons.person,
            ),
            _buildInfoCard(
              context,
              'Email',
              studentData?['email'] ?? 'N/A',
              Icons.email,
            ),
            _buildInfoCard(
              context,
              'Student ID',
              studentData?['id']?.toString() ?? 'N/A',
              Icons.badge,
            ),
            // يمكنك إضافة المزيد من الحقول هنا لعرض بيانات أخرى
          ],
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class StudentInfo extends StatefulWidget {
//   const StudentInfo({super.key});
//
//   @override
//   State<StudentInfo> createState() => _StudentInfoState();
// }
//
// class _StudentInfoState extends State<StudentInfo> {
//   Map<String, dynamic>? studentData;
//   bool _isEditing = false;
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController? _fullNameController;
//   TextEditingController? _emailController;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchStudentData();
//   }
//
//   Future<void> _fetchStudentData() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       String uid = user.uid;
//       DocumentSnapshot studentDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .get();
//       if (studentDoc.exists) {
//         setState(() {
//           studentData = studentDoc.data() as Map<String, dynamic>?;
//           _fullNameController = TextEditingController(text: studentData?['full_name'] ?? '');
//           _emailController = TextEditingController(text: studentData?['email'] ?? '');
//         });
//       } else {
//         setState(() {
//           studentData = null;
//         });
//       }
//     } else {
//       setState(() {
//         studentData = null;
//       });
//     }
//   }
//
//   Future<void> _saveStudentData() async {
//     if (_formKey.currentState!.validate()) {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null && studentData != null) {
//         try {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .update({
//             'full_name': _fullNameController!.text,
//             'email': _emailController!.text,
//             // يمكنك إضافة المزيد من الحقول هنا
//           });
//
//
//           if (_emailController!.text != studentData!['email']) {
//             try {
//               await user.verifyBeforeUpdateEmail(_emailController!.text);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text('تم إرسال رابط التحقق إلى البريد الإلكتروني الجديد')),
//               );
//
//             } catch (authError) {
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('حدث خطأ أثناء تحديث البريد الإلكتروني: $authError')),
//               );
//             }
//           }
//
//           setState(() {
//             studentData!['full_name'] = _fullNameController!.text;
//             studentData!['email'] = _emailController!.text;
//             _isEditing = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
//           );
//         } catch (e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
//           );
//         }
//       }
//     }
//   }
//
//   Widget _buildInfoCard(
//       BuildContext context,
//       String label,
//       Widget valueWidget,
//       IconData icon,
//       ) {
//     return Card(
//       elevation: 4.0,
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(icon, color: Theme.of(context).primaryColor),
//             const SizedBox(width: 16.0),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 4.0),
//                   valueWidget,
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Info'),
//         actions: [
//           IconButton(
//             icon: Icon(_isEditing ? Icons.save : Icons.edit),
//             onPressed: () {
//               if (_isEditing) {
//                 _saveStudentData();
//               } else {
//                 setState(() {
//                   _isEditing = true;
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: studentData == null
//               ? const Center(child: CircularProgressIndicator())
//               : ListView(
//             children: [
//               _buildInfoCard(
//                 context,
//                 'Full Name',
//                 TextFormField(
//                   controller: _fullNameController,
//                   enabled: _isEditing,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال الاسم الكامل';
//                     }
//                     return null;
//                   },
//                   decoration: const InputDecoration(border: InputBorder.none),
//                   style: const TextStyle(fontSize: 18.0),
//                 ),
//                 Icons.person,
//               ),
//               _buildInfoCard(
//                 context,
//                 'Email',
//                 TextFormField(
//                   controller: _emailController,
//                   enabled: _isEditing,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال البريد الإلكتروني';
//                     }
//                     if (!value.contains('@')) {
//                       return 'الرجاء إدخال بريد إلكتروني صحيح';
//                     }
//                     return null;
//                   },
//                   decoration: const InputDecoration(border: InputBorder.none),
//                   style: const TextStyle(fontSize: 18.0),
//                 ),
//                 Icons.email,
//               ),
//               _buildInfoCard(
//                 context,
//                 'Student ID',
//                 Text(
//                   studentData?['id']?.toString() ?? 'N/A',
//                   style: const TextStyle(fontSize: 18.0),
//                 ),
//                 Icons.badge,
//               ),
//               // يمكنك إضافة المزيد من الحقول القابلة للتعديل هنا
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }