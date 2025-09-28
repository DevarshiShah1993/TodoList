import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:todo_app/features/notes/application/task_cubit.dart';
import 'package:todo_app/features/notes/data/datasources/TaskLocalDataSourceImpl.dart';
import 'package:todo_app/features/notes/data/datasources/TaskRemoteDataSourceImpl.dart';
import 'package:todo_app/features/notes/data/models/todo_model.dart';
import 'package:todo_app/features/notes/domain/task_repository_impl.dart';
import '../network/network_info.dart';

final sl = GetIt.instance; 

Future<void> init() async {
  sl.registerFactory(() => TaskCubit(taskRepository: sl()));

  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));

  sl.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<TaskLocalDataSource>(() => TaskLocalDataSourceImpl(todoBox: sl()));

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

   sl.registerLazySingleton(() {
    final dio = Dio();
    // dio.options.headers['User-Agent'] = 
    //     'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';
    
    
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
        
    return dio;
  });
  
  sl.registerLazySingleton(() => Connectivity());
  final todoBox = await Hive.openBox<Todo>('todos');
  sl.registerLazySingleton(() => todoBox);
}