import 'package:flutter/material.dart';
import 'package:todo_app/features/notes/data/models/todo_model.dart';
class TaskTile extends StatelessWidget {
  final Todo todo;
  final Function(bool?) onCompleted;
  final VoidCallback onDelete;
  // 👇 NEW: Callback for editing the task title
  final VoidCallback onEdit;

  const TaskTile({
    Key? key,
    required this.todo,
    required this.onCompleted,
    required this.onDelete,
    // 👇 ADDED: Require the new callback
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
// ... existing background definition
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: onCompleted,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
            color: todo.completed ? Colors.grey : null,
          ),
        ),
        subtitle: Text('User ID: ${todo.userId}'),
        // 👇 NEW: Edit button in the trailing position
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20.0),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:todo_app/features/notes/data/models/todo_model.dart';
// class TaskTile extends StatelessWidget {
//   final Todo todo;
//   final Function(bool?) onCompleted;
//   final VoidCallback onDelete;

//   const TaskTile({
//     Key? key,
//     required this.todo,
//     required this.onCompleted,
//     required this.onDelete,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: Key(todo.id.toString()),
//       direction: DismissDirection.endToStart,
//       onDismissed: (_) => onDelete(),
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       child: ListTile(
//         leading: Checkbox(
//           value: todo.completed,
//           onChanged: onCompleted,
//         ),
//         title: Text(
//           todo.title,
//           style: TextStyle(
//             decoration: todo.completed ? TextDecoration.lineThrough : null,
//             color: todo.completed ? Colors.grey : null,
//           ),
//         ),
//         subtitle: Text('User ID: ${todo.userId}'),
//       ),
//     );
//   }
// }