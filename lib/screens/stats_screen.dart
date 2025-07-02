import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';
import '../../main.dart' show scheduleDailyMotivationalNotifications;
import 'package:provider/provider.dart';
import '../viewmodels/stats_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../resources/strings.dart';
import '../resources/colors.dart';
import '../resources/dimens.dart';

// Schermata delle statistiche utente.
class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

// `StatefulWidget` perché lo stato dell'utente può essere modificato direttamente da questa schermata.
class _StatsScreenState extends State<StatsScreen> {
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final stats = Provider.of<StatsViewModel>(context, listen: false).userStats;
    _nicknameController.text = stats.nickname;
  }

  // Mostra un dialog per modificare il nickname.
  Future<void> _editNickname() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editNickname),
        content: TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(hintText: AppStrings.yourNewNickname),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final statsViewModel = Provider.of<StatsViewModel>(context, listen: false);
              final updated = statsViewModel.userStats.copyWith(nickname: _nicknameController.text);
              await statsViewModel.saveUserStats(updated);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = Provider.of<StatsViewModel>(context).userStats;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Expanded(
                child: Text(AppStrings.stats),
              ),
              IconButton(
                icon: const Icon(Icons.schedule, color: Colors.white),
                tooltip: AppStrings.setNotificationTime,
                onPressed: () async {
                  final notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);
                  await notificationViewModel.loadNotificationTimes();
                  final times = notificationViewModel.notificationTimes;
                  final newTimes = await showDialog<List<TimeOfDay>>(
                    context: context,
                    builder: (context) => _NotificationTimesDialog(initialTimes: times),
                  );
                  if (newTimes != null && newTimes.length == 3) {
                    await notificationViewModel.saveNotificationTimes(newTimes);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.notificationTimeUpdated)),
                    );
                    await scheduleDailyMotivationalNotifications();
                  }
                },
              ),
            ],
          ),
          backgroundColor: AppColors.purple800,
          foregroundColor: AppColors.white,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.purple900, AppColors.indigo900],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            child: ListView(
              children: [
                _buildStatsCard(stats),
                const SizedBox(height: AppDimens.verticalSpacingLarge),
                _buildAchievementsCard(stats),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card con le statistiche utente.
  Widget _buildStatsCard(UserStats stats) {
    return Card(
      color: AppColors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardBorderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardLargePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.white, size: 28),
                const SizedBox(width: AppDimens.horizontalItemSpacing),
                Text(
                  AppStrings.profile,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppDimens.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.white70),
                  onPressed: _editNickname,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.verticalSpacingMedium),
            _buildStatRow(AppStrings.nickname, stats.nickname, AppColors.white),
            _buildStatRow(AppStrings.title, stats.title, AppColors.white),
            _buildStatRow(AppStrings.level, stats.level.toString(), AppColors.white),
            _buildStatRow(AppStrings.totalXP, stats.totalXP.toString(), AppColors.white),
          ],
        ),
      ),
    );
  }

  // Card con i traguardi utente.
  Widget _buildAchievementsCard(UserStats stats) {
    final achievements = {
      'assassin': 5,
      'night lord': 10,
      'necromancer': 15,
      'the monarch of shadows': 20,
    };

    return Card(
      color: AppColors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardBorderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardLargePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.white, size: 28),
                SizedBox(width: AppDimens.horizontalItemSpacing),
                Text(
                  AppStrings.achievements,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: AppDimens.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.verticalSpacingMedium),
            _buildAchievement(AppStrings.firstStep, AppStrings.completeFirstQuest, stats.totalXP > 0),
            ...achievements.entries.map((entry) {
              final title = entry.key.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
              final level = entry.value;
              return _buildAchievement(title, AppStrings.reachLevel(level), stats.level >= level);
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Riga per una statistica.
  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.white70, fontSize: AppDimens.bodyFontSize),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: AppDimens.bodyFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Mostra un traguardo.
  Widget _buildAchievement(String title, String description, bool achieved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
            color: achieved ? AppColors.green : AppColors.white30,
            size: 24,
          ),
          const SizedBox(width: AppDimens.horizontalItemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: achieved ? AppColors.white : AppColors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimens.bodyFontSize,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: achieved ? AppColors.white70 : AppColors.white30,
                    fontSize: AppDimens.captionFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTimesDialog extends StatefulWidget {
  final List<TimeOfDay> initialTimes;
  const _NotificationTimesDialog({required this.initialTimes});

  @override
  State<_NotificationTimesDialog> createState() => _NotificationTimesDialogState();
}

class _NotificationTimesDialogState extends State<_NotificationTimesDialog> {
  late List<TimeOfDay> _times;

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.initialTimes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.setNotificationTime),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => ListTile(
          title: Text('${AppStrings.notificationTime} ${i + 1}: ${_times[i].format(context)}'),
          trailing: IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _times[i],
              );
              if (picked != null) {
                setState(() => _times[i] = picked);
              }
            },
          ),
        )),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _times),
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}