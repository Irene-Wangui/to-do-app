import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:todoapp/Pages/taskpage.dart';
import 'package:todoapp/models/task_model.dart';

class TodoListItem extends StatelessWidget {
  final Task task;
  final Function(String, bool) onStatusChange;
  final Function() onDelete;
  final Function(Task) onSave;

  const TodoListItem({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onStatusChange,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        log("clicked on ${task.id}");
        //go to the taskpage
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Taskpage(
            importedTask: task,
            onSave: (Task t) {
              onSave(t);
            },
            onDelete: (Task t) {
              onDelete();
            },
            onstatusChange: (String id, bool val) {
              return onStatusChange(id, val);
            },
          ),
        ));
      },
      leading: Checkbox(
        value: task.status == "complete",
        onChanged: (val) {
          onStatusChange(task.id!, val ?? false);
        },
      ),
      title: Row(
        children: [
          Text(
            task.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          /*  Text(description ?? "No description",  
                    overflow: TextOverflow.ellipsis, maxLines: 2), */
        ],
      ),
      subtitle: Text(
        task.description ?? "no description",
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: IconButton(onPressed: () => onDelete(), icon: Icon(Icons.delete), color: Colors.red),
    );
  }
}
