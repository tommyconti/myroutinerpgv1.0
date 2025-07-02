import 'package:flutter/material.dart';
import '../models/task.dart';
import '../resources/strings.dart';
import '../resources/colors.dart';
import '../resources/dimens.dart';

// Card che mostra una quest.
class TaskCard extends StatelessWidget {
  final Task task;

  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  // Funzione di utilità per restituire un colore diverso in base alla difficoltà.
  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return AppColors.green;
      case TaskDifficulty.medium:
        return AppColors.orange;
      case TaskDifficulty.hard:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardBorderRadiusSmall)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardInnerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onComplete != null)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: AppColors.green),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onComplete,
                    tooltip: AppStrings.complete,
                  ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.yellow),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: task.completed ? null : onEdit,
                    tooltip: AppStrings.edit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.red),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                    tooltip: AppStrings.deleteLabel,
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      color: task.completed ? AppColors.green : AppColors.white,
                      fontSize: AppDimens.bodyFontSize,
                      fontWeight: FontWeight.bold,
                      decoration: task.completed 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                ),
                if (task.completed) const Text(AppStrings.checkEmoji),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: AppDimens.verticalSpacingXSmall),
              Text(
                task.description,
                style: TextStyle(
                  color: task.completed 
                      ? AppColors.green.withOpacity(0.6)
                      : AppColors.grey,
                  fontSize: AppDimens.labelFontSize,
                ),
              ),
            ],
            const SizedBox(height: AppDimens.verticalSpacingSmall),
            Wrap(
              spacing: AppDimens.chipSpacing,
              runSpacing: AppDimens.chipRunSpacing,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.chipHorizontalPadding,
                    vertical: AppDimens.chipVerticalPadding,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getDifficultyColor(task.difficulty),
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.chipBorderRadius),
                  ),
                  child: Text(
                    '${task.difficulty.stars} ${task.difficulty.displayName}',
                    style: TextStyle(
                      color: _getDifficultyColor(task.difficulty),
                      fontSize: AppDimens.captionFontSize,
                    ),
                  ),
                ),
                if (task.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.chipHorizontalPadding,
                      vertical: AppDimens.chipVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blue),
                      borderRadius: BorderRadius.circular(AppDimens.chipBorderRadius),
                    ),
                    child: Text(
                      task.category,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: AppDimens.captionFontSize,
                      ),
                    ),
                  ),
                if (task.time.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.chipHorizontalPadding , vertical: AppDimens.chipVerticalPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.purpleAccent),
                      borderRadius: BorderRadius.circular(AppDimens.chipBorderRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: AppDimens.captionFontSize, color: AppColors.purpleAccent),
                        const SizedBox(width: AppDimens.chipInnerSpacing),
                        Text(
                          task.time,
                          style: const TextStyle(color: AppColors.purpleAccent, fontSize: AppDimens.captionFontSize),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.chipHorizontalPadding,
                    vertical: AppDimens.chipVerticalPadding,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.yellow,
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.chipBorderRadius),
                  ),
                  child: Text(
                    '+${task.difficulty.xpReward} ${AppStrings.xp}',
                    style: const TextStyle(
                      color: AppColors.yellow,
                      fontSize: AppDimens.captionFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}