//om
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/provider/themeprovider.dart';
import 'package:notes/views/splashScreen.dart';
import 'package:provider/provider.dart';

void main() async{

  //Ensuring that all the widgets are properly initialized
  WidgetsFlutterBinding.ensureInitialized();
  //After all the widgets are initialized , we initialize the firebase
  await Firebase.initializeApp(
    //the default options class is available in firebase options file , the current platform gives the platform on which our app is running
    options: DefaultFirebaseOptions.currentPlatform
  );

  //Entry point
  runApp( 
    //Registering and listening to provider changes
    ChangeNotifierProvider(create: (context) => ThemeProvider() , child: const MyApp(),)
  );
}
 
 class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //The ThemeProvider class gives the current theme to be applied to our project
      theme: Provider.of<ThemeProvider>(context).theme,
      //Here stream builder is used to maintain state of the user , i.e., to check whether the user is login or not
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: ((context, snapshot) {

          //Checking where snapshot has data , if it has that means user is already logged in
          if(snapshot.hasData) {
            return const SplashScreen(isLogin: true);
          } else {
            return const SplashScreen(isLogin: false,);
          }
        })
      ),debugShowCheckedModeBanner: false,
    );
  }
}
