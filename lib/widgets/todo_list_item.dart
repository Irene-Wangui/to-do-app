// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/Pages/taskpage.dart';
import 'package:todoapp/controllers/tasks_controller.dart';
import 'package:todoapp/models/task_model.dart';

class TodoListItem extends StatelessWidget {
  final TaskItem task;

  const TodoListItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final taskcontroller = TasksController.to;
    return ListTile(
      onTap: () {
        log("clicked on ${task.id}");
        //go to the taskpage
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Taskpage(
            importedTask: task,
          ),
        ));
      },
      leading: Checkbox(
        value: task.status == "complete",
        onChanged: (val) {
          taskcontroller.onItemStatusChange(id: task.id!, val: val ?? false);
        },
      ),
      title: Row(
        children: [
          Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          if (kDebugMode)
            Text(task.id!.substring(0, 4),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ))
          /*  Text(description ?? "No description",  
                    overflow: TextOverflow.ellipsis, maxLines: 2), */
        ],
      ),
      subtitle: Text(
        task.description ?? "no description",
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: IconButton(
          onPressed: () => taskcontroller.onItemDelete(task.id!), icon: const Icon(Icons.delete), color: Colors.red),
    );
  }
}
