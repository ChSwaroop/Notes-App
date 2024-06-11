// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:notes/views/sign.dart';
import 'package:notes/util/styles.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context).colorScheme;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text("NOTES" , style: h1textStyle.copyWith(
          color: theme.primary,
          letterSpacing: 2
        ),),
        centerTitle: true,
        backgroundColor: theme.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
            ),
            child: Image.asset('assets/images/notes.png'),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text("KEEP YOUR THOUGHTS" , style: h1textStyle.copyWith(
                      fontSize: (width < 312) ? 22 : 26,
                  ),),
                  Text("ORGANIZED" , style: h1textStyle.copyWith(
                      fontSize: (width < 312) ? 22 : 26,
                  ),),
                ],
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Sign()));
                },
                child: Container(
                  height: 50,
                  width: double.infinity-100,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: radius
                  ),
                  child: Center(child: Text('Get Started' , style: h2textStyle.copyWith(color: theme.surface),)),
                ),
              ),
          const Spacer(),
        ]),
      ),
    );
  }
}
