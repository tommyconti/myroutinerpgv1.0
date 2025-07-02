import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'services/notification_service.dart';
import 'services/motivation_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'services/storage_service.dart';
import 'package:provider/provider.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/stats_viewmodel.dart';
import 'viewmodels/preset_routines_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/motivation_viewmodel.dart';
import 'repositories/task_repository.dart';
import 'repositories/user_stats_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/preset_routines_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  if (isAllowed) {
    await scheduleDailyMotivationalNotifications();
  }

  runApp(const MyApp());
}

Future<void> scheduleDailyMotivationalNotifications() async {
  await NotificationService.cancelAll();
  final times = await StorageService.getNotificationTimes();
  for (int i = 0; i < times.length; i++) {
    final quote = await MotivationService.fetchMotivationalQuote();
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, times[i].hour, times[i].minute);
    final next = scheduled.isAfter(now) ? scheduled : scheduled.add(const Duration(days: 1));
    await NotificationService.scheduleMotivationalNotification(
      id: i + 1,
      title: 'Daily Quote',
      body: quote,
      scheduledTime: next,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel(repository: TaskRepository())),
        ChangeNotifierProvider(create: (_) => StatsViewModel(repository: UserStatsRepository())),
        ChangeNotifierProvider(create: (_) => NotificationViewModel(repository: NotificationRepository())),
        ChangeNotifierProvider(create: (_) => MotivationViewModel()),
        ChangeNotifierProvider(create: (_) => PresetRoutinesViewModel(repository: PresetRoutinesRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyRoutine RPG',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
