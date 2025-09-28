import 'package:dio/dio.dart';
import 'package:todo_app/core/utils/constatnts.dart';
import 'package:todo_app/features/notes/data/models/todo_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(Todo todo);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(int id);
  Future<Todo> updateTodoTitle(int id, String newTitle);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  

  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Todo>> getTodos() async {
    try {
      final response = await dio.get(Constants.baseUrl);
      return (response.data as List)
          .map((json) => Todo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load todos');
    }
  }

  @override
  Future<Todo> addTodo(Todo todo) async {
    try {
      final response = await dio.post(Constants.baseUrl, data: todo.toJson());
      return Todo.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add todo');
    }
  }

  @override
  Future<Todo> updateTodoTitle(int id, String newTitle) async {
    try {
      // Use PATCH to update only the title field
      final response = await dio.patch(
        '${Constants.baseUrl}/$id',
        data: {'title': newTitle},
      );
      return Todo.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update todo title');
    }
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    try {
      final response = await dio.patch(
        '${Constants.baseUrl}/${todo.id}',
        data: {'completed': todo.completed},
      );
      return Todo.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update todo');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await dio.delete('${Constants.baseUrl}/$id');
    } catch (e) {
      throw Exception('Failed to delete todo');
    }
  }
}
