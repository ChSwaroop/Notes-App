// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:notes/views/displaynotes.dart';
import 'package:notes/util/reuse.dart';
import 'package:notes/util/styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  TextEditingController Search = TextEditingController();
  String searchString = "";

  List<Tab> tabs = [
    const Tab(
      child: Text('All'),
    ),
    const Tab(
      child: Text('Work'),
    ),
    const Tab(
      child: Text('Study'),
    ),
    const Tab(
      child: Text('Personal'),
    ),
    const Tab(
      child: Text('Other'),
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 5, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
        child: Column(children: [
          //Search bar
          Reusable.textField(context, 'Search Notes', Search,
          //callback to update the search string
              onChange: (value) {
            setState(() {
              searchString = value;
            });
          }),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: 5),
            child: TabBar(
              tabs: tabs,
              controller: tabController,
              labelColor: (theme.brightness == Brightness.light)
                  ? Colors.white
                  : Colors.black,
              labelStyle: h2textStyle,
              indicator: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
            ),
          ),
          Expanded(
              child: TabBarView(
            controller: tabController,
            children: [
              //Calling the list of notes available in that user account and sending category to be displayed
              NotesList(searchString: searchString, category: 'all'),
              NotesList(searchString: searchString, category: 'work'),
              NotesList(searchString: searchString, category: 'study'),
              NotesList(searchString: searchString, category: 'personal'),
              NotesList(searchString: searchString, category: 'other'),
            ],
          )),
        ]),
      ),
    );
  }
}
