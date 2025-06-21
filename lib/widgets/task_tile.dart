import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggle;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Checkbox(value: task.completed, onChanged: onToggle),
        title: Text(
          task.text,
          style: TextStyle(
            fontSize: 16,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? Colors.grey : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Color.fromARGB(255, 164, 110, 212),
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
