import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:todo_app/features/notes/application/task_cubit.dart';
import 'package:todo_app/features/notes/application/task_state.dart';
import 'package:todo_app/features/notes/data/models/todo_model.dart';
import 'package:todo_app/features/notes/presentation/TaskTile.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadTasks();
    _searchController.addListener(() {
      context.read<TaskCubit>().filterTasks(_searchController.text);
    });
  }

  void _onRefresh() async {
    await context.read<TaskCubit>().loadTasks();
    _refreshController.refreshCompleted();
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Task title'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  context.read<TaskCubit>().addTask(titleController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Todo todo) {
    final TextEditingController titleController = TextEditingController(text: todo.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task Title'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'New task title'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && titleController.text != todo.title) {
                  context.read<TaskCubit>().updateTaskTitle(todo.id!, titleController.text, _searchController.text);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
        title: const Text('Todo Tasks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is TaskLoading && (state is! TaskLoaded || (state as TaskLoaded).allTodos.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskLoaded) {
            if (state.filteredTodos.isEmpty) {
              return const Center(child: Text('No tasks found.'));
            }
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              header: const WaterDropHeader(),
              child: ListView.builder(
                itemCount: state.filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = state.filteredTodos[index];
                  return TaskTile(
                    todo: todo,
                    onCompleted: (_) => context.read<TaskCubit>().toggleTaskCompletion(todo),
                    onDelete: () => context.read<TaskCubit>().deleteTask(todo.id!),
                    // 👇 ADDED: Pass the edit function
                    onEdit: () => _showEditTaskDialog(context, todo),
                  );
                },
              ),
            );
          }

           if (state is TaskError && (state is! TaskLoaded || (state as TaskLoaded).allTodos.isEmpty)) {
             return Center(child: Text('Failed to load tasks: ${state.message}'));
           }
          return const Center(child: Text('Pull to refresh tasks.'));
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}