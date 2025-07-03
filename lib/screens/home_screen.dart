import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_header.dart';
import 'task_form_screen.dart';
import 'stats_screen.dart';
import 'preset_routines_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/notification_service.dart';
import '../services/motivation_service.dart';
import '../../main.dart' show scheduleDailyMotivationalNotifications;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../viewmodels/task_viewmodel.dart';
import '../viewmodels/stats_viewmodel.dart';
import '../resources/strings.dart';
import '../resources/colors.dart';
import '../resources/dimens.dart';

// HomeScreen: schermata principale dell'app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await StorageService.removeOldTasks();
      Provider.of<TaskViewModel>(context, listen: false).loadTasks();
      Provider.of<StatsViewModel>(context, listen: false).loadUserStats();
    });
  }

  UserStats get _userStats => Provider.of<StatsViewModel>(context).userStats;

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskViewModel>(context).tasks;
    final today = DateTime.now();
    final todayTasks = tasks.where((task) =>
      task.date.year == today.year &&
      task.date.month == today.month &&
      task.date.day == today.day).toList();
    final completedToday = todayTasks.where((task) => task.completed).length;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientPurple,
              AppColors.gradientIndigo,
              AppColors.gradientViolet,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            child: Column(
              children: [
                StatsHeader(
                  userStats: _userStats,
                  onStatsPressed: () async {
                    final updatedStats = await Navigator.push<UserStats>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatsScreen(),
                      ),
                    );
                    if (updatedStats != null) {
                      _updateUserStats(updatedStats);
                    }
                  },
                ),
                const SizedBox(height: AppDimens.verticalSpacingMedium),
                Expanded(
                  child: Card(
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.star, color: AppColors.blue),
                                  SizedBox(width: AppDimens.horizontalSpacingLarge),
                                  Text(
                                    AppStrings.homeTodaysQuests,
                                    style: TextStyle(
                                      color: AppColors.blue,
                                      fontSize: AppDimens.subtitleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.iconHorizontalPadding,
                                  vertical: AppDimens.iconVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.blue),
                                  borderRadius: BorderRadius.circular(AppDimens.cardBorderRadiusSmall),
                                ),
                                child: Text(
                                  '$completedToday/${todayTasks.length}',
                                  style: const TextStyle(color: AppColors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.verticalSpacingMedium),
                          Expanded(
                            child: todayTasks.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 48,
                                          color: AppColors.blue,
                                        ),
                                        SizedBox(height: AppDimens.verticalSpacingMedium),
                                        Text(
                                          AppStrings.homeNoQuests,
                                          style: TextStyle(
                                            color: AppColors.blue,
                                            fontSize: AppDimens.bodyFontSize,
                                          ),
                                        ),
                                        Text(
                                          AppStrings.homeCreateFirstMission,
                                          style: TextStyle(
                                            color: AppColors.blue,
                                            fontSize: AppDimens.labelFontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: todayTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = todayTasks[index];
                                      return TaskCard(
                                        task: task,
                                        onComplete: () => _toggleCompleteTask(task.id),
                                        onEdit: () async {
                                          final updatedTask = await Navigator.push<Task>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TaskFormScreen(task: task),
                                            ),
                                          );
                                          if (updatedTask != null) {
                                            await _updateTask(updatedTask);
                                          }
                                        },
                                        onDelete: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(AppStrings.homeDeleteQuest),
                                              content: Text(AppStrings.homeDeleteConfirm),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text(AppStrings.cancel),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _deleteTask(task.id);
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppDimens.verticalSpacingMedium),
                
                // Azioni rapide
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final task = await Navigator.push<Task>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TaskFormScreen(),
                            ),
                          );
                          if (task != null) {
                            await _addTask(task);
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(AppStrings.newQuest),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppDimens.captionFontSize),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.cardBorderRadiusSmall),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.horizontalSpacingLarge),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final count = await StorageService.getRandomQuestCount();
                          if (count >= 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(AppStrings.randomQuestLimit)),
                            );
                            return;
                          }
                          final response = await http.get(Uri.parse('https://bored-api.appbrewery.com/random'));
                          if (response.statusCode == 200) {
                            final data = json.decode(response.body);
                            final title = data['activity'] ?? AppStrings.randomQuest;
                            final description = '';
                            final now = DateTime.now();
                            final quest = Task(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              description: description,
                              category: 'Random Quest',
                              difficulty: TaskDifficulty.easy,
                              time: '',
                              date: DateTime(now.year, now.month, now.day),
                              completed: false,
                            );
                            await Provider.of<TaskViewModel>(context, listen: false).addTask(quest);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(AppStrings.randomQuestError)),
                            );
                          }
                        },
                        child: const Text(AppStrings.randomQuest, style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppDimens.captionFontSize)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppDimens.captionFontSize),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.cardBorderRadiusSmall),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.horizontalSpacingLarge),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final tasks = await Navigator.push<List<Task>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PresetRoutinesScreen(),
                            ),
                          );
                          if (tasks != null) {
                            for (final task in tasks) {
                              await _addTask(task);
                            }
                          }
                        },
                        icon: const Icon(Icons.track_changes, color: Colors.white),
                        label: const Text(AppStrings.routine),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppDimens.captionFontSize),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.cardBorderRadiusSmall),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.verticalSpacingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSnackBar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Ripianifica le notifiche motivazionali.
  Future<void> _rescheduleNotifications() async {
    await NotificationService.cancelAll();
    await Future.delayed(const Duration(milliseconds: 500));
    await scheduleDailyMotivationalNotifications();
  }

  Future<void> _updateUserStats(UserStats stats) async {
    await Provider.of<StatsViewModel>(context, listen: false).saveUserStats(stats);
    setState(() {});
  }

  Future<void> _completeTask(String taskId) async {
    final statsViewModel = Provider.of<StatsViewModel>(context, listen: false);
    await Provider.of<TaskViewModel>(context, listen: false).completeTask(taskId, statsViewModel);
    setState(() {});
  }

  Future<void> _deleteTask(String taskId) async {
    await Provider.of<TaskViewModel>(context, listen: false).deleteTask(taskId);
    setState(() {});
  }

  Future<void> _updateTask(Task updatedTask) async {
    await Provider.of<TaskViewModel>(context, listen: false).updateTask(updatedTask);
    setState(() {});
  }

  Future<void> _addTask(Task task) async {
    await Provider.of<TaskViewModel>(context, listen: false).addTask(task);
    setState(() {});
  }

  Future<void> _toggleCompleteTask(String taskId) async {
    final statsViewModel = Provider.of<StatsViewModel>(context, listen: false);
    await Provider.of<TaskViewModel>(context, listen: false).toggleCompleteTask(taskId, statsViewModel);
    setState(() {});
  }
}