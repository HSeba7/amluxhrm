import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/image_constants.dart';
import '../core/utils/size_utils.dart';
import 'homeScreen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => Sizer(builder: (context, orientation, deviceType) {
            return const HomeScreen();
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage(ImageConstants.ambluxIcon),
          height: 100,
        ),
      ),
      // ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
