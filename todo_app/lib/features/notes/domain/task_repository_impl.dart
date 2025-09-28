

import 'package:todo_app/core/network/network_info.dart';
import 'package:todo_app/features/notes/data/datasources/TaskLocalDataSourceImpl.dart';
import 'package:todo_app/features/notes/data/datasources/TaskRemoteDataSourceImpl.dart';
import 'package:todo_app/features/notes/data/models/todo_model.dart';

abstract class TaskRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(Todo todo);
  Future<Todo> updateTodo(Todo todo);
  Future<void> deleteTodo(int id);
}

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Todo>> getTodos() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTodos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(remoteTodos);
        return remoteTodos;
      } catch (e) {
        // If API fails, fallback to cache
        return await localDataSource.getCachedTodos();
      }
    } else {
      return await localDataSource.getCachedTodos();
    }
  }
  
  @override
  Future<Todo> addTodo(Todo todo) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.addTodo(todo);
      } catch (e) {
        throw Exception('Failed to add todo on server.');
      }
    }
    throw Exception('No internet connection.');
  }
  
  @override
  Future<Todo> updateTodo(Todo todo) async {
    if (await networkInfo.isConnected) {
       try {
        return await remoteDataSource.updateTodo(todo);
      } catch (e) {
        throw Exception('Failed to update todo on server.');
      }
    }
    throw Exception('No internet connection.');
  }
  
  @override
  Future<void> deleteTodo(int id) async {
     if (await networkInfo.isConnected) {
       try {
        await remoteDataSource.deleteTodo(id);
      } catch (e) {
        throw Exception('Failed to delete todo on server.');
      }
    } else {
      throw Exception('No internet connection.');
    }
  }
}