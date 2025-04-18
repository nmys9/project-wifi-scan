import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorInfo extends StatefulWidget {
  const DoctorInfo({super.key});

  @override
  State<DoctorInfo> createState() => _DoctorInfoState();
}

class _DoctorInfoState extends State<DoctorInfo> {
  Map<String, dynamic>? doctorData;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _fullNameController;
  TextEditingController? _emailController;

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('users') // نفترض أن بيانات الدكتور موجودة في مجموعة 'users'
          .doc(uid)
          .get();
      if (doctorDoc.exists && (doctorDoc.data() as Map<String, dynamic>?)?['role'] == 'doctor') {
        setState(() {
          doctorData = doctorDoc.data() as Map<String, dynamic>?;
          _fullNameController = TextEditingController(text: doctorData?['full_name'] ?? '');
          _emailController = TextEditingController(text: doctorData?['email'] ?? '');
        });
      } else {
        setState(() {
          doctorData = null;
        });
      }
    } else {
      setState(() {
        doctorData = null;
      });
    }
  }

  Future<void> _saveDoctorData() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && doctorData != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'full_name': _fullNameController!.text,
            'email': _emailController!.text,
            // يمكنك إضافة المزيد من الحقول المشتركة هنا
          });
          setState(() {
            doctorData!['full_name'] = _fullNameController!.text;
            doctorData!['email'] = _emailController!.text;
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
          );
        }
      }
    }
  }

  Widget _buildInfoCard(
      BuildContext context,
      String label,
      Widget valueWidget,
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
                  valueWidget,
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
        title: const Text('Doctor Info'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveDoctorData();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: doctorData == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              _buildInfoCard(
                context,
                'Full Name',
                TextFormField(
                  controller: _fullNameController,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الكامل';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(fontSize: 18.0),
                ),
                Icons.person,
              ),
              _buildInfoCard(
                context,
                'Email',
                TextFormField(
                  controller: _emailController,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'الرجاء إدخال بريد إلكتروني صحيح';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(fontSize: 18.0),
                ),
                Icons.email,
              ),
              _buildInfoCard(
                context,
                'Doctor ID',
                Text(
                  doctorData?['id']?.toString() ?? 'N/A',
                  style: const TextStyle(fontSize: 18.0),
                ),
                Icons.badge,
              ),
              // يمكنك إضافة المزيد من الحقول المشتركة هنا
            ],
          ),
        ),
      ),
    );
  }
}