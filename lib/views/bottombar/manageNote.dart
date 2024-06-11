// ignore_for_file: unused_import, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/DBreop/CRUDrepo.dart';
import 'package:notes/util/reuse.dart';
import 'package:notes/util/styles.dart';

class Note extends StatefulWidget {
  final isEdit;
  final Map<dynamic, dynamic>? noteDetails;

  const Note({required this.isEdit, this.noteDetails, super.key});

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> with SingleTickerProviderStateMixin {
  final _key = GlobalKey<FormState>();
  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  TextEditingController category = TextEditingController();
  List<XFile> file = [];
  List<dynamic> uploadImages = [];
  late AnimationController? controller;
  late Animation? animation;
  ImagePicker picker = ImagePicker();
  Reference ref = FirebaseStorage.instance.ref();
  late Reference folder;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    folder = ref.child('images');

    if (widget.isEdit) {
      title.text = widget.noteDetails!['title']!;
      content.text = widget.noteDetails!['content']!;
      category.text = widget.noteDetails!['category']!;
      if (widget.noteDetails!.containsKey('images') &&
          widget.noteDetails!['images'] != null) {
        uploadImages.addAll(widget.noteDetails!['images']);
      }
      setState(() {});
    }

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animation = Tween<double>(begin: 0, end: 55).animate(controller!);

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
      appBar: (widget.isEdit)
          ? AppBar(
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
              ))
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text((widget.isEdit) ? 'Edit Your Note' : 'Add Your Note',
                      style: h1textStyle),
                  const SizedBox(
                    height: 20,
                  ),
                  Reusable.textField(context, 'Enter the title', title),
                  const SizedBox(
                    height: 20,
                  ),
                  Reusable.textField(
                      context, 'Enter the type study/work/personal/other', category),
                  const SizedBox(
                    height: 20,
                  ),
                  Reusable.textField(context, 'Enter the content', content),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(360)),
                        width: animation!.value * 2 + 58,
                        child: Stack(
                          children: [
                            Positioned(
                                left: animation!.value,
                                child: btn(theme, Icons.camera,
                                    Colors.grey.withOpacity(0.3), () async {
                                    //Taking images from camera
                                  XFile? cameraImage = await picker.pickImage(
                                      source: ImageSource.camera);
                                  file.add(cameraImage!);
                                  setState(() {});
                                })),
                            Positioned(
                                left: (animation!.value) * 2,
                                child: btn(theme, Icons.photo,
                                    Colors.grey.withOpacity(0.3), () async {
                                  //Taking images from gallery
                                  List<XFile> galleryImages =
                                      await picker.pickMultiImage();
                                  file.addAll(galleryImages);
                                  setState(() {});
                                })),
                            Positioned(
                                child:
                                    btn(theme, Icons.add, theme.onSurface, () {
                              toggle();
                            })),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          'Attach Images',
                          style: h2textStyle,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  (isLoading)
                      ? const CircularProgressIndicator()
                      : Reusable.Button('Submit', 40, theme.primary,
                          Colors.transparent, context, () async {
                          if (_key.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              List<String> URLs = [];
                              //Generating URL's for the images selected by the user.
                              for (int i = 0; i < file.length; i++) {
                                Reference image = folder.child(DateTime.now()
                                        .millisecondsSinceEpoch
                                        .toString() +
                                    i.toString());
                                await image.putFile(File(file[i].path));
                                URLs.add(await image.getDownloadURL());
                              }

                              setState(() {
                                uploadImages.addAll(URLs);
                              });
                            } catch (e) {
                              debugPrint(e.toString());
                            }

                            Map<String, dynamic> data = {
                              'title': title.text.trim(),
                              'content': content.text.trim(),
                              'category': category.text.trim(),
                              'images': uploadImages,
                            };

                            //If the note is for editing we call updatenote method or else we add the note
                            (widget.isEdit)
                                ? await CRUDOperations().updateNote(
                                    widget.noteDetails!['title']!,
                                    data,
                                    context)
                                : await CRUDOperations().addNote(data, context);
                          }

                          setState(() {
                            isLoading = false;
                            file.clear();
                            title.text = '';
                            content.text = '';
                            category.text = '';
                            uploadImages.clear();
                            toggle();
                          });
                        }),
                  const SizedBox(
                    height: 20,
                  ),
                  (uploadImages.isNotEmpty)
                      ? Row(
                          children: [
                            Text(
                              'Attached Images',
                              style: h1textStyle,
                            ),
                          ],
                        )
                      : const SizedBox(),
                  (uploadImages.isNotEmpty)
                      ? Reusable.gridView(uploadImages, true, (ind) async {
                          if (!widget.isEdit) return;
                          String deletedURL = uploadImages.removeAt(ind);
                          setState(() {});

                          Map<String, dynamic> data = {
                            'title': widget.noteDetails!['title'],
                            'category': widget.noteDetails!['category'],
                            'content': widget.noteDetails!['content'],
                            'imageURL': uploadImages,
                          };

                          debugPrint(data.toString());

                          await CRUDOperations()
                              .deleteImage(data, deletedURL, context);
                          setState(() {});
                        }, widget.isEdit, context)
                      : const SizedBox(),
                  (file.isNotEmpty)
                      ? Row(
                          children: [
                            Text(
                              'Newly added',
                              style: h1textStyle,
                            ),
                          ],
                        )
                      : const SizedBox(),
                  (file.isNotEmpty)
                      ? Reusable.gridView(file, false, (ind) {
                          file.remove(file[ind]);
                          setState(() {});
                        }, true, context)
                      : const SizedBox(),
                ]),
          ),
        ),
      ),
    );
  }

  Widget btn(ColorScheme theme, IconData icon, Color color, callback) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(360), color: color),
        child: Transform.rotate(
            angle: (color == theme.onSurface) ? animation!.value * 0.5 : 0,
            child: Icon(
              icon,
              color:
                  (color != theme.onSurface) ? theme.onSurface : theme.surface,
            )),
      ),
    );
  }
}
