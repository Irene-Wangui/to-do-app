import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:todoapp/controllers/auth_contoller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:todoapp/controllers/tasks_controller.dart';
import 'package:todoapp/theme/styles.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final authcontroller = AuthController.to;
  XFile? selectedProfile;
  final tasksController = TasksController.to;
  bool isUploadingProfileImage = false;

  Future<void> changeProfile() async {
    XFile? changedProfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (user != null) {
      setState(() {
        isUploadingProfileImage = true;
      });
      await tasksController.uploadProfile(userId: user!.uid, file: File(changedProfile!.path)).then((downloadUrl) {
        if (downloadUrl != null) {
          log("Profile picture uploaded. Download URL: $downloadUrl");

          user!.updatePhotoURL(downloadUrl);
          setState(() {
            selectedProfile = changedProfile;
          });
          //the firestore fn called
          tasksController.updateUserDoc(user!, downloadUrl);
        } else {
          log("Profile picture upload failed.");
        }
      });

      setState(() {
        isUploadingProfileImage = false;
      });
    }
  }

  Future<void> showSignOutDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Sign Out"),
          content: const Text("Are you sure you want to sign out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authcontroller.Signout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You have been signed out.')),
                );
              },
              child: const Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("No user logged in. Please sign in."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuAnchor(
              builder: (context, controller, child) {
                if (isUploadingProfileImage) {
                  return Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: SpinKitChasingDots(
                      size: 21,
                      color: $styles.colors.accent,
                    ),
                  );
                }
                return InkWell(
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: selectedProfile != null
                        ? FileImage(File(selectedProfile!.path))
                        : user?.photoURL != null
                            ? CachedNetworkImageProvider(user!.photoURL!)
                            : null,
                    child: user?.photoURL == null && selectedProfile == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                          )
                        : null,
                  ),
                );
              },
              menuChildren: [
                MenuItemButton(
                  onPressed: () {
                    changeProfile();
                  },
                  child: const Text("Change Profile"),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display the user's name and email
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Name: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                  user?.displayName ?? "No Name Provided",
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Email: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                  user?.email ?? "No Email Provided",
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                onPressed: showSignOutDialog,
                child: const Text("Sign Out"),
              ),
            ),

            //Spacer(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
