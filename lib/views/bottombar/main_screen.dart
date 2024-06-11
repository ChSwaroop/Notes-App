// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:notes/DBreop/authrepo.dart';
import 'package:notes/provider/themeprovider.dart';
import 'package:notes/util/styles.dart';
import 'package:notes/views/bottombar/home.dart';
import 'package:notes/views/bottombar/manageNote.dart';
import 'package:notes/views/bottombar/profile.dart';
import 'package:notes/views/bottombar/shared.dart';
import 'package:notes/views/onBoard.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  //Items for bottom navigation bar
  final List<SalomonBottomBarItem> _items = [
    SalomonBottomBarItem(
        icon: const Icon(Icons.home), title: const Text('Home')),
    SalomonBottomBarItem(
        icon: const Icon(Icons.note_add), title: const Text('Add')),
    SalomonBottomBarItem(
        icon: const Icon(Icons.share), title: const Text('Shared')),
    SalomonBottomBarItem(
        icon: const Icon(Icons.account_circle), title: const Text('Profile')),
  ];
  //maintaing index for checking the current selected item in bottom navigation bar
  int _cuurentIndex = 0;
  //Screens list for display in the body
  final List<Widget> _screens = [
    const HomeScreen(),
    const Note(isEdit: false),
    const SharedNotes(),
    const Profile()
  ];
  
  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        bottomOpacity: 0,
        title: Text(
          'NOTES',
          style: h1textStyle.copyWith(letterSpacing: 2 , color: theme.primary),
        ),
        centerTitle: true,
      ),
      body: _screens[_cuurentIndex],
      bottomNavigationBar: Card(
        margin: const EdgeInsets.all(14).copyWith(top: 0),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
        child: SalomonBottomBar(
            selectedItemColor: theme.primary,
            selectedColorOpacity: 0.25,
            currentIndex: _cuurentIndex,
            itemPadding: EdgeInsets.symmetric(
                vertical: 10, horizontal: (width < 320) ? 10 : 16),
            onTap: (val) {
              setState(() {
                _cuurentIndex = val;
              });
            },
            items: _items),
      ),
    );
  }
}
