import 'package:flutter/material.dart';

class UserTypeItem extends StatelessWidget{
  UserTypeItem({
    super.key,
    required this.name,
    required this.imagePath
  });

  final String name;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints.tightFor(
                  width: 200,),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Image.asset(imagePath, width: 120, height: 120),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}