import 'package:hive/hive.dart';
import 'package:todo_app/features/notes/data/models/todo_model.dart';

abstract class TaskLocalDataSource {
  Future<List<Todo>> getCachedTodos();
  Future<void> cacheTodos(List<Todo> todos);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Box<Todo> todoBox;

  TaskLocalDataSourceImpl({required this.todoBox});

  @override
  Future<void> cacheTodos(List<Todo> todos) async {
    await todoBox.clear();
    for (var todo in todos) {
      await todoBox.put(todo.id, todo);
    }
  }

  @override
  Future<List<Todo>> getCachedTodos() async {
    return todoBox.values.toList();
  }
}