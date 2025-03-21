import 'package:flutter/material.dart';


class UserFormTextField extends StatelessWidget{
  UserFormTextField({this.onChanged,this.hintText});

  Function(dynamic)? onChanged;
  String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (data){
        if(data!.isEmpty){
          return 'field is required';
        }
      },
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.black,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.black
          ),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
      ),
    );

  }
}