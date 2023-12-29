import 'dart:async';

import 'package:flutter/material.dart';

import 'login.dart';
//import 'package:google_map_live/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 2),
            () => {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginForm()))
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset('assets/images/courage.jpeg'))
      //  Center(
      //   child: Text(
      //     'COURAGE ERP',
      //     textAlign: TextAlign.center,
      //   ),
      // ),

      // body: GeneralExceptionWidget(
      //   onPress: () {},
      // ),

      //   body: const Image(image: AssetImage(ImageAssets.oms)),
      //   floatingActionButton: FloatingActionButton(onPressed: () {
      //     Utils.toastMessageCenter('Hello Ali');
      //   }),
    );
  }
}
