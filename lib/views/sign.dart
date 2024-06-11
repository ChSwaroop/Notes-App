import 'package:flutter/material.dart';
import 'package:notes/views/signIn.dart';
import 'package:notes/views/signUp.dart';
import 'package:notes/util/styles.dart';

class Sign extends StatefulWidget {

  const Sign({super.key});

  @override
  State<Sign> createState() => _SignState();
}

class _SignState extends State<Sign> with SingleTickerProviderStateMixin{

  //Declaration of tab controller for TabBar
  late TabController tb;

  List<Tab> tabs = [
    const Tab(
      text: "Sign Up",
    ),
    const Tab(
      text: "Sign In",
    )
  ];
  
  @override
  void initState() {
    super.initState();
    tb = TabController(length: 2, vsync: this , initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context).colorScheme;
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.background,
          elevation: 0,
          bottomOpacity: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal:15.0 , vertical: 10),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              height: size.height/1.8,
              width: double.infinity-100,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: theme.primary
                      )
                    ),
                    padding: const EdgeInsets.all(0),
                    height: 50,
                    child: TabBar(
                      tabs: tabs,
                      controller: tb,
                      labelColor: (theme.brightness == Brightness.light) ? Colors.white : Colors.black,
                      labelStyle: h2textStyle,
                      indicator: BoxDecoration(
                        color: theme.primary,
                        borderRadius: BorderRadius.circular(16)
                      ),
                      dividerColor: Colors.transparent,
                      tabAlignment: TabAlignment.fill,
                      indicatorSize: TabBarIndicatorSize.tab,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    height: size.height/1.8-70,
                    width: double.infinity,
                    child: TabBarView(
                      controller: tb,
                      children: const [
                      SignUp(),
                      SignIn()
                    ]),
                  )
                ],
              ),
            ),
            
          ),
        )
      ),
    );
  }
}