import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:todoapp/controllers/auth_contoller.dart';
import 'package:todoapp/models/task_model.dart';

class TasksController extends GetxController {
  //move upload task here
  static TasksController get to => Get.find();
  final tasks = <Task>[].obs;

  @override
  void onInit() async {
    super.onInit();

    tasks.value = await fetchUserTasks();
  }

  Future<Task> uploadTask(Task task) async {
    final db = FirebaseFirestore.instance;

    final authController = AuthController.to;

    //get the current uswer id from the auth controller
    task.uid = authController.user.value!.uid;
    //create a firebase user doc to get vtyhe doc id

    DocumentReference ref = db.collection('tasks').doc();

    //asign the ref id to the tasks as the id
    task.id = ref.id;

    //asign and upload the referenced doc
    await ref.set(task.toJson(firebaseFormat: true)).then((v) {
      log("uploaded task ${task.id}:${task.title}");
      tasks.add(task);
    }).catchError((e, s) {
      log("Error adding to Firestore: $e\n$s");
    });

    return task;
  }

  Future<List<Task>> fetchUserTasks() async {
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    List<Task> t = [];

    if (user == null) {
      throw Exception("cannot fetch documents for null user");
    }

    await db.collection("tasks").where("uid", isEqualTo: user.uid).get().then(
      (querySnapshot) {
        log("Successfully completed");
        t = querySnapshot.docs.map((e) => Task.fromMap(e.data())).toList();
        /*  for (var docSnapshot in querySnapshot.docs) {
          log('${docSnapshot.id} => ${docSnapshot.data()}');
        } */
      },
      onError: (e) => log("Error completing: $e"),
    );
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

  Future<void> onItemStatusChange({required String id, required bool val}) async {
    final db = FirebaseFirestore.instance;
    String newstatus = val ? "complete" : "incomplete";
    await db.collection("tasks").doc(id).update({
      "status": newstatus,
    });
  }
}
