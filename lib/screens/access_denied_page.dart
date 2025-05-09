import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});
  static const String id = 'AccessDeniedPage';

  void _signOutAndReturn(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, Login.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline,
           size: 40,
           color: Color.fromARGB(255, 151, 175, 214),
           ),
           const SizedBox(height: 18),
           const Text('You do not have permission to access this section.',
           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
           textAlign:  TextAlign.center,
           ),
           const SizedBox(height: 20),
           ElevatedButton.icon(onPressed: () => _signOutAndReturn(context),
           icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 195, 174, 129),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  ),
 );
}
}