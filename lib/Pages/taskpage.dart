import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:todoapp/models/task_model.dart';

class Taskpage extends StatefulWidget {
  final Task importedTask;
  final Function(Task) onSave;
  final Function(Task) onDelete;
  final Function(String, bool) onstatusChange;
  const Taskpage(
      {super.key,
      required this.importedTask,
      required this.onSave,
      required this.onDelete,
      required this.onstatusChange});

  @override
  State<Taskpage> createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  late Task task;
  late TextEditingController descriptionController;
  XFile? image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      task = widget.importedTask;
      descriptionController = TextEditingController(text: task.description);
    });
  }

  Future<void> selectImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      image = pickedImage;
    });
  }

  void saveTask() {
    Task updatedTask = Task(
      id: task.id,
      title: task.title,
      description: descriptionController.text,
      status: task.status,
      createdDate: task.createdDate,
      dueDate: task.dueDate,
    );

    widget.onSave(updatedTask);

    log("updated task: ${updatedTask.toJson()}");
  }

  void deleteTask() async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('delete task'),
          content: const Text("are you sure you want to delete this text?"),
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
      widget.onDelete(task);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(task.title),
        actions: [
          IconButton(
              onPressed: () {
                log("should edit");
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                log("should delete");
                deleteTask();
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          //crossAxisAlignment: CrossAxisAlignment.center,
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
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Duedate: "),
                        Text(
                          task.dueDate == null ? "pick a duedate" : DateFormat.yMMMEd().format(task.dueDate!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Attach file", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 7),
                OutlinedButton(
                  onPressed: () {
                    log("should attach file");
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                log('pressed on add photo');
                                selectImage();
                              },
                              child: const Row(
                                children: [
                                  Text("Add Photo"),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                log('pressed on add file');
                              },
                              child: const Row(
                                children: [
                                  Text("Add file"),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                  ),
                  child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(
                        minHeight: 100,
                      ),
                      child: image != null
                          ? Image.file(
                              File(image!.path),
                              height: 200,
                            )
                          : Icon(MdiIcons.fileUpload, size: 42)),
                ),
                CheckboxListTile(
                  value: task.status == "complete",
                  onChanged: (value) {
                    setState(() {
                      widget.onstatusChange(task.id!, value ?? false);
                    });
                  },
                  title: const Text("mark as complete/incomplete"),
                  subtitle: Text(task.status == "complete" ? "Task is complete" : "Task is incomplete"),
                ),
                ElevatedButton(
                    onPressed: () {
                      log("should save");
                      saveTask();
                      Navigator.pop(context);
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("SAVE"),
                        SizedBox(width: 12),
                        Icon(Icons.save),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
