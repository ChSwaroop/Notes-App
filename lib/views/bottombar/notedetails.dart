// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/DBreop/CRUDrepo.dart';
import 'package:notes/util/reuse.dart';
import 'package:notes/util/styles.dart';
import 'package:notes/views/bottombar/manageNote.dart';

class Details extends StatefulWidget {
  final Map<dynamic, dynamic> data;
  const Details({required this.data, super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> with SingleTickerProviderStateMixin {
  TextEditingController search = TextEditingController();
  late AnimationController? controller;
  late Animation? animation;
  List<Map<dynamic, dynamic>> userData = [];
  var shareUsers = [];
  Map<String, dynamic> map = {};
  String searchUser = "";
  List<Map<dynamic, dynamic>> users = [];
  bool isSending = false;
  bool isInfo = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animation = Tween<double>(begin: 0, end: 65).animate(controller!);

    controller!.addListener(() {
      setState(() {});
    });
  }

  void toggle() {
    if (controller!.isCompleted) {
      controller!.reverse();
    } else {
      controller!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        bottomOpacity: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 66,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(360),
              color: Colors.grey.withOpacity(0.3),
            ),
            child: const Center(child: Icon(Icons.arrow_back)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.data['title'],
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
                textScaler: const TextScaler.linear(1.3),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        widget.data['content'],
                        style: h2textStyle,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  )),
              const SizedBox(
                height: 30,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(360)),
                      width: animation!.value *
                              ((widget.data.containsKey('sharedby')) ? 1 : 2) +
                          68,
                      child: Stack(
                        children: [
                          (widget.data.containsKey('sharedby'))
                              ? const SizedBox()
                              : Positioned(
                                  left: animation!.value,
                                  child: btn(theme, Icons.edit,
                                      Colors.grey.withOpacity(0.3), () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) => Note(
                                                  isEdit: true,
                                                  noteDetails: widget.data,
                                                ))));
                                  })),
                          Positioned(
                              left: (animation!.value) *
                                  ((widget.data.containsKey('sharedby'))
                                      ? 1
                                      : 2),
                              child: btn(theme, Icons.ios_share_outlined,
                                  Colors.grey.withOpacity(0.3), () async {
                                setState(() {
                                  isInfo = true;
                                });
                                await getData();
                                setState(() {
                                  isInfo = false;
                                });
                                //bottom sheet for display for sharing the note
                                showModalBottomSheet(
                                    backgroundColor: theme.background,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return bottomSheet(setState);
                                      });
                                    }).whenComplete(() {
                                  shareUsers = [];
                                  setState(() {});
                                });
                              })),
                          Positioned(
                              child: btn(theme, Icons.add, theme.onSurface, () {
                            toggle();
                          })),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    (isInfo)
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox(),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              (widget.data.containsKey('images') &&
                      widget.data['images'] != null &&
                      widget.data['images'].length != 0)
                  ? Text(
                      'Attached Images',
                      style: h1textStyle,
                    )
                  : const SizedBox(),
              (widget.data.containsKey('images') &&
                      widget.data['images'] != null)
                  ? Reusable.gridView(widget.data['images'], true,
                      (ind) async {}, false, context)
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget btn(ColorScheme theme, IconData icon, Color color, callback) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(360), color: color),
        child: Transform.rotate(
            angle: (color == theme.onSurface) ? animation!.value * 0.302 : 0,
            child: Icon(
              icon,
              color:
                  (color != theme.onSurface) ? theme.onSurface : theme.surface,
            )),
      ),
    );
  }

  Widget bottomSheet(StateSetter setState) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      width: double.infinity,
      child: Column(
        children: [
          //Search funtionality for searching an user based on userName
          Reusable.textField(context, 'Search User', search, onChange: (val) {
            setState(() {
              searchUser = val;
              users = userData.where((e) {
                if (searchUser.trim().isNotEmpty) {
                  return (e['uid'] != FirebaseAuth.instance.currentUser!.uid) &&
                      (e['userName'].contains(searchUser.trim()));
                } else {
                  return (e['uid'] != FirebaseAuth.instance.currentUser!.uid);
                }
              }).toList();
            });
          }),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, ind) {
                  //Checking the list of shared users
                  debugPrint(users.length.toString());
                  for (int i = 0; i < shareUsers.length; i++) {
                    debugPrint('${shareUsers[i]}');
                  }
                  var isPresent = (shareUsers.contains(users[ind]['uid']));
                  bool isprofilePhoto =
                      (users[ind].containsKey('profilePhoto') &&
                          users[ind].containsKey('profilePhoto') != null);

                  return (users[ind]['uid'] !=
                          FirebaseAuth.instance.currentUser!.uid)
                      ? ListTile(
                          leading: (isprofilePhoto)
                              ? Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(360),
                                      color: Colors.grey.shade300),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(360),
                                    child: Image.network(
                                        users[ind]['profilePhoto'],
                                        fit: BoxFit.cover, errorBuilder:
                                            (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.account_circle,
                                        size: 35,
                                      );
                                    }),
                                  ))
                              : const Icon(
                                  Icons.account_circle,
                                  size: 35,
                                ),
                          title: Text(
                            users[ind]['userName'],
                            style: h2textStyle,
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              //Adding the users to the list for sharing note
                              if (shareUsers.contains(users[ind]['uid'])) {
                                shareUsers.remove(users[ind]['uid']);
                              } else {
                                shareUsers.add(users[ind]['uid']);
                              }
                              debugPrint('added');
                              debugPrint(shareUsers.toList().toString());
                              setState(() {});
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.primary),
                                borderRadius: BorderRadius.circular(360),
                                color: isPresent
                                    ? theme.primary
                                    : Colors.transparent,
                              ),
                              child: isPresent
                                  ? Center(
                                      child: Icon(
                                      Icons.check,
                                      color: theme.surface,
                                    ))
                                  : null,
                            ),
                          ),
                        )
                      : const SizedBox();
                }),
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                isSending = true;
              });

              final cur = userData.where((val) {
                return val['uid'] == FirebaseAuth.instance.currentUser!.uid;
              }).toList();
              //Sharing the note to users by calling share note method of auth repository
              await CRUDOperations()
                  .shareNote(widget.data, context, shareUsers, cur[0]['email']);
              setState(() {
                isSending = false;
              });
              debugPrint('Added');
            },
            child: (isSending)
                ? const CircularProgressIndicator()
                : Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(360),
                        color: theme.primary),
                    child: Center(
                        child: Text(
                      'Send',
                      style: h2textStyle.copyWith(color: theme.surface),
                    )),
                  ),
          )
        ],
      ),
    );
  }

  //Function to fetch the user data from cloud firestore
  Future<void> getData() async {
    QuerySnapshot data =
        await FirebaseFirestore.instance.collection('userDetails').get();
    var dt = data.docs;
    var temp = dt.map((e) => e.data() as Map).toList();
    setState(() {
      userData = users = temp;
    });
  }
}
