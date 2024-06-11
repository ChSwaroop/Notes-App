// ignore_for_file: unused_import, prefer_typing_uninitialized_variables, curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:notes/DBreop/CRUDrepo.dart';
import 'package:notes/util/reuse.dart';
import 'package:notes/util/styles.dart';
import 'package:notes/views/bottombar/notedetails.dart';

class NotesList extends StatefulWidget {
  final category;
  final String searchString;

  const NotesList(
      {required this.searchString, required this.category, super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  bool isUndo = false;

  //snackbar to display deleted message and undo button
  void snackbar(Map<dynamic, dynamic> data) {
    ColorScheme theme = Theme.of(context).colorScheme;

    final snackbar = SnackBar(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
        margin: const EdgeInsets.all(10),
        backgroundColor: theme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Note deleted',
              style: TextStyle(color: theme.onSurface),
            ),
            //Undo button for undoing the deleted note
            TextButton(
                onPressed: () async {
                  Map<String, dynamic> dt = {
                    'title': data['title'],
                    'content': data['content'],
                    'category': data['category'],
                    'images': data['images']
                  };
                  await CRUDOperations().addNote(dt, context);
                },
                child: const Text('Undo'))
          ],
        ));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  bool isLoading = false;
  List<String> categories = ['all', 'work', 'personal', 'study'];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ColorScheme theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      //Using stream builder for listening to the notes stream of the particular user
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .collection('notes')
              .snapshots(),
          builder: (context, snapshot) {
            //snapshot is in still loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Reusable.loading(context);
            }
            //checking whether data present in data or not
            else if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              return const Center(child: Text("No notes added yet"));
            else {
              final data =
                  //Filtering the data based on the category of the data
                  (widget.category == 'other')
                      ? ((widget.searchString.trim().isNotEmpty)
                          ? snapshot.data!.docs.where((doc) {
                              return (!categories.contains(doc['category']
                                      .toString()
                                      .toLowerCase())) &&
                                  doc['title']
                                      .toString()
                                      .toLowerCase()
                                      .contains(
                                          widget.searchString.toLowerCase());
                            })
                          : snapshot.data!.docs.where((doc) {
                              return (!categories.contains(
                                  doc['category'].toString().toLowerCase()));
                            }))
                      : (widget.category != 'all')
                          ? ((widget.searchString.trim().isNotEmpty)
                              ? snapshot.data!.docs.where((doc) {
                                  return doc['catergory']
                                              .toString()
                                              .toLowerCase() ==
                                          widget.category &&
                                      doc['title']
                                          .toString()
                                          .toLowerCase()
                                          .contains(widget.searchString
                                              .toLowerCase());
                                }).toList()
                              : snapshot.data!.docs.where((doc) {
                                  return doc['category']
                                          .toString()
                                          .toLowerCase() ==
                                      widget.category;
                                }).toList())
                          : (widget.searchString.trim().isNotEmpty)
                              ? snapshot.data!.docs.where((doc) {
                                  return doc['title']
                                      .toString()
                                      .toLowerCase()
                                      .contains(
                                          widget.searchString.toLowerCase());
                                }).toList()
                              : snapshot.data!.docs;

              //Converting the data to a map format
              List<Map> notes = data.map((e) => e.data() as Map).toList();

              return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, ind) {
                    String content = notes[ind]['content'];
                    content = (content.length > 30)
                        ? content.substring(0, 11)
                        : content;

                    return GestureDetector(
                      //On tapping a particular note the notes details are displayed in Details screen
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    Details(data: notes[ind]))));
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: radius),
                        elevation:
                            (theme.brightness == Brightness.light) ? 0 : 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        surfaceTintColor: theme.primary,
                        child: Container(
                            padding: const EdgeInsets.all(15),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: theme.surface, borderRadius: radius),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(360)),
                                      child: Text(
                                        '#${notes[ind]['category']}',
                                        style: h3textStyle,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                        width: size.width / 1.9,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notes[ind]['title'],
                                              style: h1textStyle,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Text('$content........')
                                          ],
                                        ))
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    bool res = await CRUDOperations()
                                        .deleteNote(
                                            notes[ind]['title'], context);
                                    if (res) {
                                      snackbar(notes[ind]);
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(360)),
                                    child: const Icon(Icons.delete),
                                  ),
                                )
                              ],
                            )),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
