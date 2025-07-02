import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../viewmodels/preset_routines_viewmodel.dart';
import '../repositories/preset_routines_repository.dart';
import '../models/routine.dart';
import '../resources/strings.dart';
import '../services/storage_service.dart';
import '../resources/colors.dart';
import '../resources/dimens.dart';

// Schermata delle routine preimpostate.
class PresetRoutinesScreen extends StatelessWidget {
  const PresetRoutinesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PresetRoutinesViewModel(repository: PresetRoutinesRepository())..loadPresetRoutines(),
      child: Consumer<PresetRoutinesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(AppStrings.errorPrefix + '${viewModel.error}'));
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.presetRoutinesTitle),
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
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                itemCount: viewModel.presetRoutines.length,
                itemBuilder: (context, index) {
                  final routine = viewModel.presetRoutines[index];
                  return Column(
                    children: [
                      _buildRoutineCard(context, routine),
                      const SizedBox(height: AppDimens.verticalSpacingMedium),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Card per una routine preimpostata.
  Widget _buildRoutineCard(BuildContext context, Routine routine) {
    return Card(
      color: AppColors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardBorderRadius)),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.cardBorderRadius),
        onTap: () async {
          final selectedIds = await StorageService.getSelectedRoutinesToday();
          if (selectedIds.contains(routine.title)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.routineAlreadySelected)),
            );
            return;
          }
          await StorageService.saveSelectedRoutineToday(routine.title);
          Navigator.pop(context, routine.tasks);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.cardLargePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.cardInnerPadding),
                    decoration: BoxDecoration(
                      color: routine.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimens.inputBorderRadius),
                    ),
                    child: Icon(routine.icon, color: routine.color, size: 28),
                  ),
                  const SizedBox(width: AppDimens.horizontalSpacingLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          routine.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: AppDimens.subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimens.verticalSpacingXSmall),
                        Text(
                          routine.description,
                          style: const TextStyle(
                            color: AppColors.white70,
                            fontSize: AppDimens.labelFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.verticalSpacingMedium),
              Text(
                '${AppStrings.includedQuests} ${routine.tasks.length}',
                style: TextStyle(
                  color: routine.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimens.verticalSpacingSmall),
              Wrap(
                spacing: AppDimens.chipWrapSpacing,
                children: routine.tasks.map((task) => Chip(
                  label: Text(
                    task.title,
                    style: const TextStyle(fontSize: AppDimens.captionFontSize),
                  ),
                  backgroundColor: routine.color.withOpacity(0.2),
                  labelStyle: TextStyle(color: routine.color),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}