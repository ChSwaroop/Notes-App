// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/util/styles.dart';

class CRUDOperations {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance.collection('users');
  final users = FirebaseFirestore.instance.collection('userDetails');

  void snackbar(String txt, BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;

    final snackBar = SnackBar(
      content: Text(
        txt,
        style: TextStyle(color: theme.onSurface),
      ),
      margin: const EdgeInsets.all(10),
      backgroundColor: theme.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radius),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> addNote(Map<String, dynamic> data, BuildContext context) async {
    try {
      await db
          .doc(auth.currentUser!.uid)
          .collection('notes')
          .doc(data['title'])
          .set({
        'title': data['title'],
        'content': data['content'],
        'category': data['category'],
        // Maintaing server timestamp so the time will be synchronized correctly
        'timeStamp': FieldValue.serverTimestamp(),
        'images': data['images']
      });

      debugPrint('Successfully added note');
      snackbar('Successfully added', context);
    } on FirebaseException catch (e) {
      debugPrint("Error: ------${e.code}------------");
      snackbar(e.code, context);
    }
  }

  Future<bool> deleteNote(String title, BuildContext context) async {
    try {
      await db
          .doc(auth.currentUser!.uid)
          .collection('notes')
          .doc(title)
          .delete();
      return true;
    } on FirebaseException catch (e) {
      debugPrint(e.code);
      snackbar(e.code, context);
    }
    return false;
  }

  Future<void> updateNote(
      String oldTitle, Map<String, dynamic> data, BuildContext context) async {
    try {
      await db
          .doc(auth.currentUser!.uid)
          .collection('notes')
          .doc(data['title'])
          .update({
        'title': data['title'],
        'content': data['content'],
        'category': data['category'],
        // Maintaing server timestamp so the time will be synchronized correctly
        'timeStamp': FieldValue.serverTimestamp(),
        'images': data['images']
      });
      debugPrint('Note updated');
      snackbar('Note Updated', context);
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        await deleteNote(oldTitle, context);
        await addNote(data, context);
      } else {
        debugPrint(e.code);
        snackbar(e.code, context);
      }
    }
  }

  Future<void> shareNote(
      var data, BuildContext context, List users, String sharedBy) async {
    try {
      
      for (int i = 0; i < users.length; i++) {
        await db
            .doc(users[i])
            .collection('sharedNotes')
            .doc(data['title'])
            .set({
          'title': data['title'],
          'content': data['content'],
          'category': data['category'],
          'images': data['images'],
          'timeStamp': FieldValue.serverTimestamp(),
          'sharedby': sharedBy,
        });
      }
      Navigator.pop(context);
      snackbar('Shared ', context);
    } on FirebaseException catch (e) {
      debugPrint(e.code);
      snackbar(e.code, context);
    }
  }

  Future<void> deleteImage(Map<String, dynamic> data, String deletedURL,
      BuildContext context) async {
        
    try {
      await FirebaseStorage.instance.refFromURL(deletedURL).delete();
      await db
          .doc(auth.currentUser!.uid)
          .collection('notes')
          .doc(data['title'])
          .update({'images': data['imageURL']});

      snackbar('Succesfully deleted', context);
    } on FirebaseException catch (e) {
      debugPrint(e.code);
      snackbar(e.code, context);
    }
  }

  Future<void> updateProfilePhoto(XFile? file, BuildContext context) async {
    Reference ref = FirebaseStorage.instance.ref();
    Reference folderReference = ref.child('images');
    Reference imageReference =
        folderReference.child(DateTime.now().microsecondsSinceEpoch.toString());

    try {
      await imageReference.putFile(File(file!.path));
      final url = await imageReference.getDownloadURL();
      await users.doc(auth.currentUser!.uid).update({
        'profilePhoto': url,
      });

      Navigator.pop(context);
      snackbar('Updated', context);
    } on FirebaseException catch (e) {
      debugPrint(e.code);
      snackbar(e.code, context);
    }
  }

  Future<void> deleteProfilePhoto(String url, BuildContext context) async {
    try {
      await FirebaseStorage.instance.refFromURL(url).delete();
      await users.doc(auth.currentUser!.uid).update({'profilePhoto': null});

      Navigator.pop(context);
      snackbar('Profile removed', context);
    } on FirebaseException catch (e) {
      debugPrint(e.code);
      snackbar(e.code, context);
    }
  }
}
