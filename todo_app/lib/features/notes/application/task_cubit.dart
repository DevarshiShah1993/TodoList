import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/notes/data/models/todo_model.dart';
import 'package:todo_app/features/notes/domain/task_repository_impl.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository taskRepository;

  TaskCubit({required this.taskRepository}) : super(TaskInitial());

  Future<void> loadTasks() async {
    try {
      emit(TaskLoading());
      final todos = await taskRepository.getTodos();
      emit(TaskLoaded(allTodos: todos, filteredTodos: todos));
    } catch (e) {
      emit(TaskError(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  void filterTasks(String query) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      if (query.isEmpty) {
        emit(TaskLoaded(allTodos: currentState.allTodos, filteredTodos: currentState.allTodos));
      } else {
        final filtered = currentState.allTodos
            .where((todo) => todo.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
        emit(TaskLoaded(allTodos: currentState.allTodos, filteredTodos: filtered));
      }
    }
  }
  
  Future<void> addTask(String title) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final newTodo = Todo(userId: 1, title: title, completed: false);

      final optimisticList = List<Todo>.from(currentState.allTodos)..insert(0, newTodo.copyWith(id: 0)); 
      emit(TaskLoaded(allTodos: optimisticList, filteredTodos: optimisticList));

      try {
        await taskRepository.addTodo(newTodo);
        await loadTasks(); 
      } catch (e) {
        emit(TaskError(e.toString().replaceFirst("Exception: ", "")));
        emit(currentState); 
      }
    }
  }

  Future<void> toggleTaskCompletion(Todo todo) async {
     if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final updatedTodo = todo.copyWith(completed: !todo.completed);

      final optimisticList = currentState.allTodos.map((t) => t.id == todo.id ? updatedTodo : t).toList();
      emit(TaskLoaded(allTodos: optimisticList, filteredTodos: optimisticList));

      try {
        await taskRepository.updateTodo(updatedTodo);
      } catch (e) {
        emit(TaskError(e.toString().replaceFirst("Exception: ", "")));
        emit(currentState); // Revert
      }
    }
  }
  
   Future<void> updateTaskTitle(int id, String newTitle, String filteredText) async {
    if (state is! TaskLoaded) return;

    final currentState = state as TaskLoaded;
    final originalTodo = currentState.allTodos.firstWhere((t) => t.id == id, orElse: () => throw Exception("Task not found"));
    final updatedTodo = originalTodo.copyWith(title: newTitle);
    

    final optimisticAllList = currentState.allTodos.map((todo) {
      return todo.id == id ? updatedTodo : todo;
    }).toList();
    
    final filteredListAfterUpdate = optimisticAllList
          .where((t) => t.title.toLowerCase().contains(filteredText.toLowerCase()))
          .toList();

    emit(TaskLoaded(
      allTodos: optimisticAllList,
      filteredTodos: filteredListAfterUpdate,
    ));

    try {
      await taskRepository.updateTodo(updatedTodo);
      
    } catch (e) {
      final rolledBackAllList = currentState.allTodos.map((t) => t.id == id ? originalTodo : t).toList();
      
      final rolledBackFilteredList = rolledBackAllList
            .where((t) => t.title.toLowerCase().contains(filteredText.toLowerCase()))
            .toList();

      emit(TaskError(e.toString().replaceFirst("Exception: ", "")));
      
      emit(TaskLoaded(
        allTodos: rolledBackAllList,
        filteredTodos: rolledBackFilteredList,
      ));
    }
  }
  

  Future<void> deleteTask(int id) async {
     if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;

      // Optimistic Update
      final optimisticList = currentState.allTodos.where((t) => t.id != id).toList();
      emit(TaskLoaded(allTodos: optimisticList, filteredTodos: optimisticList));

      try {
        await taskRepository.deleteTodo(id);
      } catch (e) {
        emit(TaskError(e.toString().replaceFirst("Exception: ", "")));
        emit(currentState); // Revert
      }
    }
  }
}