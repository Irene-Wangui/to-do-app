// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mime/mime.dart';
import 'package:todoapp/controllers/tasks_controller.dart';
import 'package:todoapp/models/task_model.dart';
import 'package:todoapp/cloud_file_widget.dart';

class Taskpage extends StatefulWidget {
  final TaskItem importedTask;

  const Taskpage({
    super.key,
    required this.importedTask,
  });

  @override
  State<Taskpage> createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  final tasksController = TasksController.to;
  late TextEditingController descriptionController;
  XFile? image;
  List<File> selectedFiles = [];
  List<File> cloudFiles = [];
  List<File> downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    //initiate file fetch
    tasksController.downloadTaskFiles(taskId: widget.importedTask.id!).then((files) {
      setState(() {
        cloudFiles = files;
      });
      cloudFiles.forEach((file) {
        log("File ${file.path.split("/").last}: ${file.path}");
      });
    }).catchError((e) {
      log("Error fetching task files: $e");
    });
  }

  Future<void> selectImages() async {
    List<XFile?> pickedImages = await ImagePicker().pickMultiImage();
    for (var i = 0; i < pickedImages.length; i++) {
      if (pickedImages[i] == null) {
        continue;
      }
      setState(() {
        selectedFiles.add(File(pickedImages[i]!.path));
      });
    }
  }

  Future<void> selectFiles() async {
    final pickedFiles = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (pickedFiles != null) {
      List<File> files = pickedFiles.paths.map((path) => File(path!)).toList();
      setState(() {
        selectedFiles.addAll(files);
      });
    } else {}
  }

  void saveTask(TaskItem task) {
    TaskItem updatedTask = TaskItem(
      id: task.id,
      title: task.title,
      description: descriptionController.text,
      status: task.status,
      createdDate: task.createdDate,
      dueDate: task.dueDate,
      //attachments: existingAttachments,
    );

    onSave(updatedTask);
    log("updated task: ${updatedTask.toJson()}");
  }

  void onSave(TaskItem t) async {
    log("saving task: ${t.id}: ${t.title}");
    int index = tasksController.tasks.indexWhere((e) => e.id == t.id);
    setState(() {
      tasksController.tasks[index] = t;
    });
    log("Task page pre-upload");
    await tasksController.uploadTask(t, selectedFiles);
    log("Task ${t.id} saved");
    Navigator.pop(context);
  }

  void deleteTask(String id) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('delete task'),
          content: const Text("are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete) {
      tasksController.onItemDelete(id);
      Navigator.pop(context);
    }
  }

  void editTaskTitle(TaskItem task) async {
    TextEditingController titleController = TextEditingController(text: task.title);

    bool shouldUpdate = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit task'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "save changes",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
    if (shouldUpdate == true && titleController.text.trim().isNotEmpty) {
      setState(() {
        task.title = titleController.text.trim();
      });
      log("Updated Task Title: ${task.title}");
    }
  }

  void showSelectorModal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 20),
            TextButton(
              child: const Row(children: [Text('Add Photo')]),
              onPressed: () async {
                log("clicked add photo");
                await selectImages();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Row(children: [Text('Add file')]),
              onPressed: () async {
                log("clicked added file");
                await selectFiles();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetX(
      init: TasksController(),
      builder: (_) {
        TaskItem task = tasksController.tasks.firstWhere((e) => e.id == widget.importedTask.id);
        descriptionController = TextEditingController(text: task.description);
        return LoadingOverlay(
          isLoading: tasksController.isuploadingTasks.value,
          progressIndicator: CircularProgressIndicator(),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(task.title),
              actions: [
                IconButton(
                    onPressed: () {
                      editTaskTitle(widget.importedTask);
                    },
                    icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: () {
                      deleteTask(task.id!);
                    },
                    icon: const Icon(Icons.delete)),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  SizedBox(
                    height: 100,
                    child: TextField(
                      controller: descriptionController,
                      maxLines: 10,
                      minLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Task description',
                        hintText: 'Add a description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GetBuilder<TasksController>(builder: (controller) {
                        final task = controller.tasks.firstWhere((e) => e.id == widget.importedTask.id);
                        return CheckboxListTile(
                          value: task.status == "complete",
                          onChanged: (value) {
                            setState(() {
                              tasksController.onItemStatusChange(id: task.id!, val: value ?? false);
                            });
                          },
                          title: const Text("mark as complete/incomplete"),
                          subtitle: Text(task.status == "complete" ? "Task is complete" : "Task is incomplete"),
                        );
                      }),
                      Row(
                        children: [
                          const Text('Due Date: '),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: task.dueDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  task.dueDate = pickedDate;
                                });
                              }
                            },
                            child:
                                Text(task.dueDate != null ? DateFormat.yMMMEd().format(task.dueDate!) : 'Pick a date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Attach file", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 7),
                      OutlinedButton(
                        onPressed: () {
                          showSelectorModal();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 100),
                          child: image != null
                              ? Image.file(File(image!.path), height: 200)
                              : Icon(MdiIcons.fileUpload, size: 42),
                        ),
                      ),
                      Text('cloud files'),
                      ...cloudFiles.map((e) => CloudFileWidget(cloudFile: e, task: task)),
                      ...selectedFiles.map((e) {
                        final mimeType = lookupMimeType(e.path);
                        String? fileType = mimeType?.split("/").first;
                        switch (fileType) {
                          case "image":
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: Row(
                                children: [
                                  Spacer(),
                                  Image.file(File(e.path)),
                                  Spacer(),
                                  IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red.shade900),
                                      onPressed: () {
                                        setState(() {
                                          selectedFiles.removeWhere((e2) => e2.path == e.path);
                                        });
                                      })
                                ],
                              ),
                            );
                          case "application":
                          case "audio":
                          case "text":
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 3),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.zero),
                              child: Row(
                                children: [
                                  Text(e.path.split("/").last),
                                  Spacer(),
                                  IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red.shade900),
                                      onPressed: () {
                                        setState(() {
                                          selectedFiles.removeWhere((e2) => e2.path == e.path);
                                        });
                                      })
                                ],
                              ),
                            );
                          default:
                            return Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
                              child: Text("Unsupported File Type"),
                            );
                        }
                      }),
                      ElevatedButton(
                          onPressed: () {
                            showSelectorModal();
                          },
                          child: Text("Add image/file")),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            saveTask(task);
                          },
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [Text("SAVE"), SizedBox(width: 8), Icon(Icons.save)]),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
