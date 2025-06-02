import 'package:flutter/material.dart';
import 'package:pgiconnect/service/appcolor.dart';

class ProgressWithIcon extends StatelessWidget {
  const ProgressWithIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            // you can replace this with Image.asset
            'assets/images/pgilogo.png',
            fit: BoxFit.fill,
            height: 30,
            width: 30,
          ),
          // you can replace
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Appcolor.primary),
            strokeWidth: 5,
          ),
        ],
      ),
    );
  }
}
