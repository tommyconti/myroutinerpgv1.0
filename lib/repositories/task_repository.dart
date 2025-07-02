// Repository per la gestione delle quest (Task)
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskRepository {
  Future<List<Task>> loadTasks() async {
    return await StorageService.getTasks();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await StorageService.saveTasks(tasks);
  }
} 