// ignore_for_file: unnecessary_cast, curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/DBreop/CRUDrepo.dart';
import 'package:notes/util/reuse.dart';
import 'package:notes/util/styles.dart';
import 'package:notes/views/bottombar/notedetails.dart';

class SharedNotes extends StatefulWidget {
  const SharedNotes({super.key});

  @override
  State<SharedNotes> createState() => _SharedNotesState();
}

class _SharedNotesState extends State<SharedNotes> {
  void snackbar(var data) {
    final snackbar = SnackBar(
        content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Note deleted'),
        TextButton(
            onPressed: () {
              Map<String, dynamic> dt = {
                'title': data['title'],
                'content': data['content'],
                'category': data['category'],
                'images': data['images']
              };
              CRUDOperations().addNote(dt, context);
            },
            child: const Text('Undo'))
      ],
    ));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('sharedNotes')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Reusable.loading(context);
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              return const Center(child: Text("No one has shared notes to you yet"));
            else {
              final data = snapshot.data!.docs;
              List<Map> noteDetails = data.map((e) => e.data() as Map).toList();

              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, ind) {
                    String content = noteDetails[ind]['content'];
                    content = (content.length > 30)
                        ? content.substring(0, 11)
                        : content;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    Details(data: noteDetails[ind]))));
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
                                        '#${noteDetails[ind]['category']}',
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
                                              noteDetails[ind]['title'],
                                              style: h1textStyle,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Text('$content........'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                              'Shared by: ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(noteDetails[ind]['sharedby']),
                                          ],
                                        )),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    bool res = await CRUDOperations()
                                        .deleteNote(
                                            noteDetails[ind]['title'], context);
                                    if (res) {
                                      snackbar(noteDetails[ind]);
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
    ));
  }
}
