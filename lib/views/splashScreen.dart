// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/views/bottombar/main_screen.dart';
import 'package:notes/views/onBoard.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  final bool isLogin;
  const SplashScreen({
    required this.isLogin,
    super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    
    super.initState();
    //Making the app to look in full screen for displaying splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    //After 2 seconds the respective screern will be displayed
    //If user is logged in , directly main screen will be displayed otherwise onboarding screen will be displayed
    Future.delayed(const Duration(seconds: 2) , (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => (widget.isLogin) ? const MainScreen() : const OnBoarding() )));
    });
  }

  @override
  void dispose() {
    //Setting the UI as it is before leaving this screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual , overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Theme.of(context).colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: Image.asset('assets/images/notes.png'),
            ),
              
              const SizedBox(height: 20,),
              //Shimmer effect on the text
              Shimmer.fromColors(
                baseColor: Colors.black, 
                highlightColor: Colors.grey.shade200, 
                child: const Text('NOTES' , style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}