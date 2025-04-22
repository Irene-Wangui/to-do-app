import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todoapp/controllers/auth_contoller.dart';
import 'package:todoapp/models/task_model.dart';
import 'package:todoapp/utils/show_toast.dart';

class TasksController extends GetxController {
  //move upload task here
  static TasksController get to => Get.find();
  final tasks = <TaskItem>[].obs;
  final isfetchingTasks = false.obs;
  final isuploadingTasks = false.obs;

  @override
  void onInit() async {
    super.onInit();

    tasks.value = await fetchUserTasks();
  }

  Future<TaskItem> uploadTask(TaskItem task, List<File> files) async {
    //log("We are to upload this glorious task");
    final db = FirebaseFirestore.instance;
    final authController = AuthController.to;

    if (authController.user.value == null) {
      // Throw exception, user not found
      throw "User not found";
    }
    isuploadingTasks.value = true;
    //get the current user id (uid)from the auth controller
    task.uid = authController.user.value!.uid;

    //create a firestore user doc to get the doc id
    DocumentReference ref = db.collection('tasks').doc();

    if (task.id == null) {
      ref = db.collection("tasks").doc();
    } else {
      ref = db.collection("tasks").doc(task.id);
    }
    // Assign the ref ID to the tasks, as the ID,for a task without an Id assigned
    task.id = ref.id;

    // If there are files;
    // Upload files and get the download URLs
    log("We have ${files.length} files to upload");
    List<String> urls = [];
    for (File file in files) {
      String? url = await uploadFile(taskId: task.id!, file: file);
      if (url == null || url.isEmpty) {
        continue;
      }
      urls.add(url);
    }
    // Append the urls
    if (task.attachments.isEmpty) {
      task.attachments = [];
    }
    task.attachments.addAll(urls);

    // Assign and upload the referenced doc
    await ref.set(task.toJson(firebaseFormat: true)).then((v) {
      log("uploaded task ${task.id}: ${task.title}");
      showToast(title: 'Taskuploaded', type: ToastType.successs);
      int index = tasks.indexWhere((e) => e.id == task.id);
      if (index > -1) {
        tasks[index] = task;
      } else {
        tasks.add(task);
      }
    });
    isuploadingTasks.value = false;
    update();

    return task;
  }

  Future<List<TaskItem>> fetchUserTasks() async {
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    List<TaskItem> t = [];

    if (user == null) {
      throw Exception("cannot fetch documents for null user");
    }

    isfetchingTasks.value = true;
    update();

    await db.collection("tasks").where("uid", isEqualTo: user.uid).get().then(
      (querySnapshot) {
        log("Successfully completed");
        t = querySnapshot.docs.map((e) => TaskItem.fromMap(e.data())).toList();
        /*  for (var docSnapshot in querySnapshot.docs) {
          log('${docSnapshot.id} => ${docSnapshot.data()}');
        } */
      },
      onError: (e) => log("Error completing: $e"),
    );
    isfetchingTasks.value = false;
    update();
    return t;
  }

  // Delete task fn
  Future<void> onItemDelete(String id) async {
    final db = FirebaseFirestore.instance;
    await db.collection("tasks").doc(id).delete().then((_) {
      log("item $id deleted");
      tasks.removeWhere((e) => e.id == id);
    }).catchError((e, s) {
      log("Error deleting from Firestore: $e\n$s");
    });
  }

  Future<void> onItemStatusChange(
      {required String id, required bool val}) async {
    final db = FirebaseFirestore.instance;
    String newstatus = val ? "complete" : "incomplete";
    await db.collection("tasks").doc(id).update({
      "status": newstatus,
    });
  }

  Future<String?> uploadFile(
      {required String taskId, required File file}) async {
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://smokeless-todo.firebasestorage.app")
        .ref();
    final String fileName = file.path.split("/").last;
    final taskFolderRef = storageRef.child("tasks/$taskId/$fileName");

    log("Should upload to $taskFolderRef");

    TaskSnapshot snapshot =
        await taskFolderRef.putFile(file).catchError((e, s) {
      log("There was an error uploading the file. $e\n$s");
      return;
    });

    String? downloadUrl =
        await snapshot.ref.getDownloadURL().catchError((e, s) {
      log("There was an error getting the download url. $e\n$s");
      return "";
    });
    log("Download url for $fileName: $downloadUrl");

    return downloadUrl;
  }

  Future<String?> uploadProfile(
      {required String userId, required File file}) async {
    log("Update prof pic called");
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://smokeless-todo.firebasestorage.app")
        .ref();
    final String extension = file.path.split("/").last.split(".").last;
    final String profile = 'profile.$extension';
    final profileRef = storageRef.child("img/users/$userId/$profile");

    log("Should upload profile to $profileRef");

    try {
      TaskSnapshot snapshot = await profileRef.putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      log("Download url for profile: $downloadUrl");
      return downloadUrl;
    } catch (e, s) {
      log("There was an error uploading profile: $e\n$s");
      return null;
    }
  }

  Future<void> updateUserDoc(User user, String downloadUrl) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    return await userRef.set({
      'uid': user.uid,
      'displayname': user.displayName,
      'email': user.email,
      'photouRL': user.photoURL,
      "createdDate": user.metadata.creationTime
    }, SetOptions(merge: true));
  }

  Future<List<File>> downloadTaskFiles({required String taskId}) async {
    final storageRef = FirebaseStorage.instanceFor(
            bucket: "gs://smokeless-todo.firebasestorage.app")
        .ref();
    final taskFolderRef = storageRef.child("tasks/$taskId");
    List<File> files = [];

    await taskFolderRef.listAll().then((result) async {
      //log each file in the folder
      for (var item in result.items) {
        log('taskController=>Item:${item.name}');
        //Get the file from the Item
        final appDocDir = await getApplicationDocumentsDirectory();
        final filePath = "${appDocDir.absolute}/tasks/$taskId/${item.name}";
        final file = File(filePath);
        files.add(file);
      }
    });

    return files;
  }
}
