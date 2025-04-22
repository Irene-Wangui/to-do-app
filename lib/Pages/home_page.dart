// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todoapp/Pages/my_account_page.dart';
import 'package:todoapp/Pages/taskpage.dart';
import 'package:todoapp/controllers/auth_contoller.dart';
import 'package:todoapp/controllers/notifications_controllers.dart';
import 'package:todoapp/controllers/tasks_controller.dart';
import 'package:todoapp/models/task_model.dart';
import 'package:todoapp/theme/styles.dart';
import 'package:todoapp/widgets/todo_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final authcontroller = AuthController.to;
  TasksController tasksController = Get.put(TasksController(), permanent: true);
  NotificationsController notificationsController = Get.put(NotificationsController(), permanent: true);
  DateTime? pickedDate;

  @override
  void initState() {
    super.initState();
    getFcmToken();
    listenToTokenRefresh();

    log('homepage initialized');
  }

  void getFcmToken() async {
    final db = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      log("User not logged in. Cannot upload FCM token.");
      return;
    }

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      log("Initial FCM Token: $fcmToken");

      if (fcmToken != null) {
        await db.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
        log("FCM Token updated in Firestore.");
      }
    } catch (e) {
      log("Error getting or updating FCM token: $e");
    }
  }

  void listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      log("FCM Token refreshed: $fcmToken");
    }).onError((err) {
      log("Error on token refresh: $err");
    });
  }

  void onSave(TaskItem t) {
    log("saving task: ${t.toJson()}");
    int index = tasksController.tasks.indexWhere((e) => e.id == t.id);
    setState(() {
      tasksController.tasks[index] = t;
    });
  }

  void onDelete(TaskItem t) {
    setState(() {
      tasksController.tasks.removeWhere((e) => e.id == t.id);
    });
  }

  void onStatusChange(String id, bool val) {
    log("item $id status changed to $val");
    String newStatus = val == true ? "complete" : "incomplete";
    int index = tasksController.tasks.indexWhere((e) => e.id == id);
    TaskItem t = tasksController.tasks[index];
    t.status = newStatus;
    tasksController.onItemStatusChange(id: id, val: val);
    setState(() {
      t.status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('status is $newStatus'),
        duration: const Duration(seconds: 2),
        backgroundColor: newStatus == 'complete' ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void addTask({required String title, String? description, DateTime? dueDate}) async {
    TaskItem t = TaskItem(
      title: title,
      description: description,
      status: "incomplete",
      dueDate: pickedDate,
      createdDate: DateTime.now(),
    );
    log("called add");
    await tasksController.uploadTask(t, []).catchError((e, s) {
      log("There was an error uploading the task.$e\n$s");
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added succesfully'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void onEditTask(TaskItem task) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Taskpage(
        importedTask: task,
      ),
    ));
  }

  void showAddTaskModal(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dueDateController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    DateTime? pickedDate;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Task Title'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Title cannot be empty";
                            }
                            if (value.length > 10) {
                              return "title cannot be more than 10 characters";
                            }
                            return null;
                          },
                        ),
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Task Description'),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              pickedDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (pickedDate != null) {
                                log(pickedDate!.toIso8601String());
                                setModalState(
                                  () {
                                    dueDateController.text = pickedDate!.toIso8601String();
                                  },
                                );
                              }
                            },
                            child: Text(
                              'Selected date:${dueDateController.text.isEmpty ? "Not selected" : dueDateController.text}',
                            )),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                              log("validation failed");
                              return;
                            }
                            String title = titleController.text.trim();
                            String? description = descriptionController.text.trim();
                            if (title.isNotEmpty) {
                              addTask(title: title, description: description, dueDate: pickedDate);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Add Task'),
                        ),
                      ],
                    )));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    //final tasksController = Get.put(TasksController(), permanent: true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  " Hello, ${user?.displayName!.split(' ').first ?? 'User'}",
                  style: $styles.text.headlineLarge,
                ),
                // SizedBox(height: 10),
              ],
            ),
            //Padding(
            //padding: const EdgeInsets.all(8.0),
            PopupMenuButton(
              onSelected: (value) {
                if (value == "My Account") {
                  Get.to(() => const MyAccountPage());
                } else if (value == "Logout") {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            "Sign Out",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                          ),
                          content: const Text("Are you sure you want to sign out?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                "cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                authcontroller.Signout();
                              },
                              child: const Text("log out"),
                            )
                          ],
                        );
                      });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "My Account",
                  child: Text("My Account"),
                ),
                const PopupMenuItem(value: "Logout", child: Text("log out")),
              ],
              child: CircleAvatar(
                radius: 25,
                backgroundImage: CachedNetworkImageProvider(
                  user?.photoURL ?? "https://www.example.com/default-avatar.png",
                ),
              ),
            ),
          ],
        ),
      ),
      body: GetX<TasksController>(
          init: TasksController(),
          builder: (tasksController) {
            if (tasksController.isfetchingTasks.value) {
              return Center(
                child: SpinKitThreeBounce(
                  color: $styles.colors.primary,
                  size: 40,
                ),
              );
            }
            if (tasksController.tasks.isEmpty)
              return Center(
                child: Text("No tasks yet"),
              );

            return ListView(children: [
              ...tasksController.tasks.map((item) => TodoListItem(
                    task: item,
                    onEdit: onEditTask,
                    onDelete: onDelete,
                    onStatusChange: onStatusChange,
                  )),
            ]);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTaskModal(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
