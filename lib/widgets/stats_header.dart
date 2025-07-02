import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../resources/strings.dart';
import '../resources/colors.dart';
import '../resources/dimens.dart';

// Header che mostra le statistiche utente nella home.
class StatsHeader extends StatelessWidget {
  final UserStats userStats;
  final VoidCallback onStatsPressed;

  const StatsHeader({
    super.key,
    required this.userStats,
    required this.onStatsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.black.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userStats.nickname,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppDimens.subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userStats.title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: AppDimens.labelFontSize,
                      ),
                    ),
                  ],
                ),
                // Pulsante che mostra il livello e porta alla schermata delle statistiche.
                OutlinedButton.icon(
                  onPressed: onStatsPressed,
                  icon: const Icon(Icons.person),
                  label: Text('${AppStrings.levelPrefix}${userStats.level}'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.white),
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.verticalSpacingMedium),
            // Sezione per la barra di progresso dell'XP.
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.xpProgress,
                      style: TextStyle(color: AppColors.white),
                    ),
                    Text(
                      '${userStats.xp}/100',
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.verticalSpacingSmall),
                LinearProgressIndicator(
                  value: userStats.xp / 100,
                  backgroundColor: AppColors.purple.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}