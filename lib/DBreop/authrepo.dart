// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/util/styles.dart';
import 'package:notes/views/bottombar/main_screen.dart';
import 'package:notes/views/onBoard.dart';

//Auth repository for performing authentication related operations
class AuthRepository {

  //snackbar for displaying the successfull messages and errors
  void snackbar(String txt, BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;

    final snackBar = SnackBar(
      content: Text(
        txt,
        style: TextStyle(color: theme.onSurface),
      ),
      margin: const EdgeInsets.all(30),
      backgroundColor: theme.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radius),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  //reference for auth
  var auth = FirebaseAuth.instance;
  //reference for cloud firestore
  var db = FirebaseFirestore.instance.collection('userDetails');

  Future<void> addUser(String email, String password, String userName,
      BuildContext context) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await db.doc(auth.currentUser!.uid).set({
        'email': email,
        'userName': userName,
        'password': password,
        'uid': FirebaseAuth.instance.currentUser!.uid,
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: ((context) => const MainScreen())));

      debugPrint('Sucessfully user created');
    } on FirebaseException catch (e) {
      snackbar(e.code, context);
      debugPrint(e.code);
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainScreen()));
    } on FirebaseException catch (e) {
      snackbar(e.code, context);
      debugPrint(e.code);
    }
  }

  void logout(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: ((context) => const OnBoarding())));
    } on FirebaseException catch (e) {
      snackbar(e.code, context);
      debugPrint(e.code);
    }
  }
}
