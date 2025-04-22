import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todoapp/Pages/taskpage.dart';
import 'package:todoapp/controllers/tasks_controller.dart';
import 'package:todoapp/models/task_model.dart';

class TodoListItem extends StatelessWidget {
  final TaskItem task;
  final void Function(TaskItem task)? onEdit;
  final void Function(TaskItem task)? onDelete;
  final void Function(String id, bool isComplete)? onStatusChange;

  TodoListItem({
    super.key,
    required this.task,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(task),
            icon: Icons.edit,
            backgroundColor: Colors.blue,
            label: 'Edit',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete?.call(task),
            icon: Icons.delete,
            backgroundColor: Colors.red,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        child: MenuAnchor(
          controller: _menuController,
          builder: (context, controller, child) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Taskpage(importedTask: task),
                ));
              },
              onLongPress: () => _menuController.open(), //
              leading: Checkbox(
                value: task.status == "complete",
                onChanged: (val) =>
                    onStatusChange?.call(task.id!, val ?? false),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (kDebugMode)
                    Text(task.id!.substring(0, 4),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                ],
              ),
              subtitle: Text(
                task.description ?? "no description",
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            );
          },
          menuChildren: [
            MenuItemButton(
              leadingIcon:
                  Icon(task.status == "complete" ? Icons.undo : Icons.check),
              child: Text(task.status == "complete"
                  ? "Mark Incomplete"
                  : "Mark Complete"),
              onPressed: () {
                final isComplete = task.status != "complete";
                onStatusChange?.call(task.id!, isComplete);
              },
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.edit),
              child: const Text("Edit"),
              onPressed: () => onEdit?.call(task),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.delete),
              child: const Text("Delete"),
              onPressed: () => onDelete?.call(task),
            ),
          ],
        ),
      ),
    );
  }
}
