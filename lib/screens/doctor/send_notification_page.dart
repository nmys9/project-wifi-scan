import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../../widgets/sendNotifications.dart';

class SendNotificationPage extends StatefulWidget {
  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  String selectedRole = 'student';
  List<Map<String, dynamic>> users = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final controller = MultiSelectController<Map<String, dynamic>>();


  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final allUsers = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'docId': doc.id,
      };
    }).toList();

    setState(() {
      users = allUsers.where((u) => u['role'] == selectedRole).toList();
      print("users ${users.length}");
      users.removeWhere((element) => element["docId"] == FirebaseAuth.instance.currentUser!.uid);
      controller.clearAll(); /// Clear all selected items
      controller.setItems(users
          .map((user) => DropdownItem(
        value: user,
        label: user['full_name'],
      ))
          .toList()); /// Set items of the dropdown

    });
  }

///
  Future<void> sendNotificationToUser() async {
    final selectedItems = controller.selectedItems;
    for (var element in selectedItems) {
      final fcmToken = element.value["fcm_token"] ?? "";
      final userID = element.value['docId'];
      final title = titleController.text.trim();
      final body = bodyController.text.trim();
      if (fcmToken != "") {
       await sendNotification(
            title: title,
            body: body,
            fcmToken: fcmToken,
            userID: userID,
            context: context);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification sent to all selected users")),
    );


  }

  void onRoleChanged(String role) {
    setState(() {
      selectedRole = role;
      users = users.where((u) => u['role'] == role).toList();
      // controller.selectedItems.clear();
    });
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send Notification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedRole,
              isExpanded: true,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Border radius here
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  onRoleChanged(value);
                }
              },
              items: ['student', 'doctor', 'assistant']
                  .map((role) => DropdownMenuItem(
                value: role,
                child: Text(role),
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),

            MultiDropdown<Map<String, dynamic>>(
              
              controller: controller,
              items: users
                  .map((user) => DropdownItem(
                        value: user,
                        label: user['full_name'],
              ))
                  .toList(),
              onSelectionChange: (_){
                print("onSelectionChange ");
                setState(() {});
              },
            ),

            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Notification Title",
                border: OutlineInputBorder(  borderRadius: BorderRadius.circular(12), ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(
                labelText: "Notification Body",
                border: OutlineInputBorder(  borderRadius: BorderRadius.circular(12), ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.selectedItems.isNotEmpty
                  ? () => sendNotificationToUser()
                  : null,
              child: Text("Send Notification"),
            )
          ],
        ),
      ),
    );
  }
}

