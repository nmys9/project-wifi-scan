import 'package:flutter/material.dart';


class UserFormTextField extends StatefulWidget{
  UserFormTextField({this.onChanged,this.hintText,this.isPassword=false});

  Function(dynamic)? onChanged;
  String? hintText;
  bool isPassword;

  @override
  State<UserFormTextField> createState() => _UserFormTextFieldState();
}

class _UserFormTextFieldState extends State<UserFormTextField> {
  bool _obscureText= true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _obscureText=widget.isPassword;
  }


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (data){
        if(data!.isEmpty){
          return 'field is required';
        }
      },
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
        suffixIcon: widget.isPassword
          ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: (){
              setState(() {
                _obscureText=!_obscureText;
              });
            },
          ): null
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
      ),
      obscureText: _obscureText,
    );

  }
}