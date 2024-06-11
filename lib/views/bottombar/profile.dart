import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/DBreop/CRUDrepo.dart';
import 'package:notes/DBreop/authrepo.dart';
import 'package:notes/provider/themeprovider.dart';
import 'package:notes/util/reuse.dart';
import 'package:notes/util/styles.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    setState(() {
      isLoading = false;
    });
  }

  Map<String, dynamic> userData = {};
  XFile? profile;
  bool isUpdating = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    bool isProfilePresent = (userData.containsKey('profilePhoto') &&
            userData['profilePhoto'] != null) ??
        false;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(children: [
              Stack(children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        backgroundColor: theme.background,
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return bottomSheet(setState);
                          });
                        }).whenComplete(() {
                      profile = null;
                      isUpdating = false;
                    });
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(360),
                        color: Colors.grey.withOpacity(0.5)),
                    child: isProfilePresent
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(360),
                            child: (isLoading)
                                ? Reusable.shimmer(150, 150)
                                : Image.network(
                                    userData['profilePhoto'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, object, stack) {
                                      return const Center(
                                        child: Text('??'),
                                      );
                                    },
                                  ),
                          )
                        : const Icon(Icons.account_circle),
                  ),
                ),
                Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(360)),
                        child: Center(
                            child: Icon(!isProfilePresent
                                ? Icons.camera_enhance_rounded
                                : Icons.edit))))
              ]),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    content(const Icon(Icons.account_circle),
                        userData['email'] ?? 'loading...'),
                    content(const Icon(Icons.abc),
                        userData['userName'] ?? 'loading...'),
                    GestureDetector(
                      onDoubleTap: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggle();
                      },
                      child: content(
                          (theme.brightness == Brightness.light)
                              ? Image.asset('assets/images/darkMode.png',
                                  fit: BoxFit.cover)
                              : Image.asset(
                                  'assets/images/lightMode.png',
                                  fit: BoxFit.cover,
                                ),
                          'Double Tap to change theme'),
                    ),
                    GestureDetector(
                        onTap: () {
                          AuthRepository().logout(context);
                        },
                        child: content(const Icon(Icons.logout), 'logout'))
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  void getData() async {
    try {
      FirebaseFirestore.instance
          .collection('userDetails')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        setState(() {
          userData = value.data()!;
        });
        debugPrint(userData.toString());
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget content(Widget icon, String txt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  height: 50,
                  width: 50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(360),
                      color: Colors.grey.withOpacity(0.3)),
                  child: icon),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(
                  txt,
                  style: h2textStyle,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget photoOptions(String txt, IconData icon, callback) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: callback,
          child: Container(
              margin: const EdgeInsets.all(3),
              height: 55,
              width: 55,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(360),
                  color: Colors.grey.withOpacity(0.3)),
              child: Icon(icon)),
        ),
        Text(txt)
      ],
    );
  }

  Widget bottomSheet(StateSetter setState) {
    ImagePicker picker = ImagePicker();
    ColorScheme theme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Photo',
                style: h1textStyle,
              ),
              (profile != null)
                  ? (isUpdating)
                      ? Text(
                          'Updating...',
                          style: h2textStyle,
                        )
                      : Reusable.Button('Update', 40, theme.primary,
                          Colors.transparent, context, () async {
                          setState(() {
                            isUpdating = true;
                          });
                          //calling update method to update user profilePhoto
                          await CRUDOperations()
                              .updateProfilePhoto(profile, context);
                          setState(() {
                            isUpdating = false;
                          });
                          getData();
                        })
                  : (isUpdating)
                      ? Text(
                          'Removing...',
                          style: h2textStyle,
                        )
                      : const SizedBox(),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(children: [
            photoOptions('Camera', Icons.camera, () async {
              //Picking the image from camera
              XFile? file = await picker.pickImage(source: ImageSource.camera);
              setState(() {
                profile = file;
              });
            }),
            const SizedBox(
              width: 30,
            ),
            photoOptions('Gallery', Icons.image, () async {
              //Picking the image from gallery.
              XFile? file = await picker.pickImage(source: ImageSource.gallery);
              setState(() {
                profile = file;
              });
            }),
            const SizedBox(
              width: 30,
            ),
            (userData.containsKey('profilePhoto') &&
                    userData['profilePhoto'] != null)
                ? photoOptions('Remove', Icons.delete, () async {
                    setState(() {
                      isUpdating = true;
                    });
                    //calling deleteprofilephoto method to remove profile photo of user
                    await CRUDOperations()
                        .deleteProfilePhoto(userData['profilePhoto'], context);
                    setState(() {
                      isUpdating = false;
                    });
                    getData();
                  })
                : const SizedBox(),
          ]),
        ],
      ),
    );
  }
}
