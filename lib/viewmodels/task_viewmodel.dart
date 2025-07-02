import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import 'stats_viewmodel.dart';
import '../repositories/task_repository.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskRepository repository;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskViewModel({required this.repository});

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await repository.loadTasks();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks.add(task);
      await repository.saveTasks(_tasks);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeTask(String taskId, StatsViewModel statsViewModel) async {
    _isLoading = true;
    notifyListeners();
    try {
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1 && !_tasks[idx].completed) {
        _tasks[idx] = _tasks[idx].copyWith(completed: true);
        await repository.saveTasks(_tasks);
        final task = _tasks[idx];
        final userStats = statsViewModel.userStats;
        int newXP = userStats.xp + task.difficulty.xpReward;
        int newLevel = userStats.level;
        int totalXP = userStats.totalXP + task.difficulty.xpReward;
        while (newXP >= 100) {
          newXP -= 100;
          newLevel++;
        }
        final updatedStats = userStats.copyWith(
          xp: newXP,
          level: newLevel,
          totalXP: totalXP,
          title: UserStats.getTitleForLevel(newLevel),
        );
        await statsViewModel.saveUserStats(updatedStats);
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks.removeWhere((t) => t.id == taskId);
      await repository.saveTasks(_tasks);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    _isLoading = true;
    notifyListeners();
    try {
      final idx = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (idx != -1) {
        _tasks[idx] = updatedTask;
        await repository.saveTasks(_tasks);
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleCompleteTask(String taskId, StatsViewModel statsViewModel) async {
    _isLoading = true;
    notifyListeners();
    try {
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        final task = _tasks[idx];
        final userStats = statsViewModel.userStats;
        int newXP = userStats.xp;
        int newLevel = userStats.level;
        int totalXP = userStats.totalXP;
        if (task.completed) {
          _tasks[idx] = task.copyWith(completed: false);
          newXP -= task.difficulty.xpReward;
          totalXP -= task.difficulty.xpReward;
          while (newXP < 0 && newLevel > 1) {
            newLevel--;
            newXP += 100;
          }
          if (newXP < 0) newXP = 0;
          if (totalXP < 0) totalXP = 0;
        } else {
          _tasks[idx] = task.copyWith(completed: true);
          newXP += task.difficulty.xpReward;
          totalXP += task.difficulty.xpReward;
          while (newXP >= 100) {
            newXP -= 100;
            newLevel++;
          }
        }
        await repository.saveTasks(_tasks);
        final updatedStats = userStats.copyWith(
          xp: newXP,
          level: newLevel,
          totalXP: totalXP,
          title: UserStats.getTitleForLevel(newLevel),
        );
        await statsViewModel.saveUserStats(updatedStats);
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 