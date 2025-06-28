import 'package:flutter/material.dart';
import 'dart:async';

import '../utils/constants.dart';
import 'Welcome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 2 seconds then navigate
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlueColor,
      body: Center(
        child: Image.asset(
          'assets/images/chevron1.png',
          width: 180, // adjust size as needed
          height: 180,
        ),
      ),
    );
  }
}
