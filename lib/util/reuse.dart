// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes/util/styles.dart';
import 'package:shimmer/shimmer.dart';

//Resuable for reusing the various components
class Reusable {
  //Button for reuse
  static GestureDetector Button(String txt, double height, Color color,
      Color borderColor, BuildContext context, callback,
      {child}) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: radius,
          color: color,
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: IntrinsicWidth(
          child: Center(
              child: (txt.isEmpty)
                  ? child
                  : Text(txt,
                      style: h2textStyle.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary))),
        ),
      ),
    );
  }

  //texfield for resuse
  static Widget textField(BuildContext context, String txt, controller,
      {onChange, isHide, callback}) {
    var theme = Theme.of(context).colorScheme;

    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.secondary,
        suffixIcon: (txt.contains('Password'))
            ? GestureDetector(
                onTap: () {
                  callback();
                },
                child: (isHide)
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off))
            : null,
        border: OutlineInputBorder(
            borderRadius: radius, borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        hintText: txt,
      ),
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Enter required data";
        } else {
          return null;
        }
      },
      onChanged: onChange,
      maxLines: (txt.contains('content')) ? 10 : 1,
      keyboardType: (txt.contains('content'))
          ? TextInputType.multiline
          : TextInputType.text,
      textInputAction: (txt.contains('content'))
          ? TextInputAction.newline
          : TextInputAction.done,
      obscureText: (txt.contains('Password')) ? isHide : false,
    );
  }

  //Grid view for displaying the images uploaded/selected by the user
  static Widget gridView(var file, bool isUploadedFiles, Function(int) callback,
      bool isEdit, BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: size.width,
      decoration: BoxDecoration(
        borderRadius: radius,
      ),
      child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: file.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 5, crossAxisSpacing: 5),
          itemBuilder: (context, ind) {
            return Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: radius),
                child: Stack(
                    alignment: Alignment.topRight,
                    fit: StackFit.expand,
                    children: [
                      Container(
                        width: (size.width / 2) - 40,
                        height: (size.width / 2) - 40,
                        decoration: BoxDecoration(
                          borderRadius: radius,
                        ),
                        child: ClipRRect(
                          borderRadius: radius,
                          child: (isUploadedFiles)
                              ? Image.network(
                                  file[ind],
                                  fit: BoxFit.cover,
                                  errorBuilder: ((context, error, stackTrace) {
                                    return const Center(
                                        child: Text('Image Not found'));
                                  }),
                                )
                              : Image.file(
                                  fit: BoxFit.cover,
                                  File(file[ind].path),
                                  errorBuilder: ((context, error, stackTrace) {
                                    return const Center(
                                        child: Text('Image Not found'));
                                  }),
                                ),
                        ),
                      ),
                      (isEdit)
                          ? Positioned(
                              top: 3,
                              right: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await callback(ind);
                                    },
                                    child: Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(360),
                                        color: Colors.grey.shade700,
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ]));
          }),
    );
  }

  //widget for showing shimmer effect for loading
  static Widget loading(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, ind) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: (theme.brightness == Brightness.light) ? 0 : 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          // shadowColor: theme.primary,
          surfaceTintColor: theme.primary,
          child: Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: radius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmer(25, 70),
                    const SizedBox(height: 20),
                    shimmer(25, 70),
                    const SizedBox(height: 20),
                    shimmer(25, 150)
                  ],
                ),
                shimmer(50, 50)
              ],
            ),
          ),
        );
      },
    );
  }

  //Shimmer
  static Widget shimmer(double height, double widht) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade500,
      highlightColor: Colors.grey.shade200,
      child: Container(
        height: height,
        width: widht,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(360), color: Colors.grey),
      ),
    );
  }
}
